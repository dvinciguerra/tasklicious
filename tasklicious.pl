#!/usr/bin/env perl

# (c) 2011 Bivee. All rights reserveds.

package Model;

use ORLite {
	file => 'tasklicious.db',
    cleanup => 'VACUUM',
    create => sub {
        my $db = shift;
        $db->do('
            CREATE TABLE "user" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                "name" TEXT NOT NULL,
                "email" TEXT NOT NULL,
                "password" TEXT NOT NULL
            )
        ');
        $db->do('
            CREATE TABLE "task" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                "title" TEXT NOT NULL,
                "description" TEXT,
                "assigned" INTEGER NOT NULL,
                "status" TEXT NOT NULL,
                "type" TEXT NOT NULL,
                "complex" TEXT NOT NULL,
                "estimated" TEXT NOT NULL,
                "tags" TEXT,
                "notification" INTEGER NOT NULL DEFAULT (1),
                "author" INTEGER NOT NULL,
                "created" DateTime
            )
        ');
    }
};

package main;

use DateTime;
use Mojolicious::Lite;

my $status = { 
    '1' => 'Opened',
    '2' => 'Waiting',
    '3' => 'Analysing',
    '4' => 'Closed',
};

my $complex = {
    '1' => 'Very Easy',
    '2' => 'Easy',
    '3' => 'Normal',
    '4' => 'Hard',
    '5' => 'Very Hard',
};

my $type = {
    '1' => 'Task',
    '2' => 'Feature',
    '3' => 'Bug',
    '4' => 'Improvement',
    '5' => 'Others',
};

# signin action
get '/signin' => { message => '' } => 'signin';
post '/signin' => sub {
	my $self = shift;

	my @list = Model::User->select('WHERE email = ? AND password = ?', 
			$self->param('username'), $self->param('password'));

	if (scalar @list > 0) {
		$self->session( 
            name => $list[0]->name,
            id => $list[0]->id,
        );
		$self->redirect_to('/');
        return;
	}

	$self->stash( 
        message => 'Username or password invalid!' 
    );
} => 'signin';

# user registration action
get '/user/registration' => 'registration';
post '/user/registration' => sub {
    my $self = shift;

    Model::User->new(
        name        => $self->param( 'name' ),
        email       => $self->param( 'email' ),
        password    => $self->param( 'password' ),
    )->insert;

    return $self->redirect_to('/signin');

} => 'registration';

# check if user is authenticated
ladder sub {
	return 1 if $_[0]->session('name');
	shift->redirect_to('/signin') and return;
};

# index action
get '/' => 'dashboard';
post '/' => sub{} => 'dashboard';

# user view action
get '/user/view/(.id)' => sub {
    my $self = shift;
    $self->stash( 
        user => Model::User->load( $self->param('id') ) 
    );
} => 'userview';

# task action
get '/task/form' => sub { 
    my $self = shift;
    $self->stash( 
        status  => $status, 
        complex => $complex,
        type    => $type,
    );
} => 'taskform';
post '/task/form' => sub {
    my $self = shift;

    Model::Task->new(
        title           => $self->param('title'),
        description     => $self->param('description'),
        assigned        => $self->param('assigned'),
        status          => $self->param('status'),
        type            => $self->param('type'),
        complex         => $self->param('complexibility'),
        estimated       => $self->param('estimated'),
        tags            => $self->param('tags'),
        notification    => $self->param('notify'),
        author          => $self->session('id'),
        created         => DateTime->now,
    )->insert;

    return $self->redirect_to('/task/form');
};

# task list action
get '/task/list' => sub {
    my $self = shift;
    
} => 'tasklist';

# signout action
get '/signout' => sub {
	$_[0]->session( expires => 1 );
	shift->redirect_to('/signin') and return;
};

app->start;
__DATA__

@@ signin.html.ep
% layout 'default';
<table width="100%" cellspacing="0">
<tr>
<td width="50%">
<h2>Tasklicious - Simple Mojo Task List</h2>
<form method="POST">
	<p><label>Username:<br />
	<input type="text" name="username" /></label></p>
	<p><label>Password:<br />
	<input type="password" name="password" /></label></p>
	<p><input type="submit" name="signin" value="Sign In" /></p>
	<p><a href="#">forgot your password?</a></p>
	<span style="color: red;"><%= $message %></span>
</form>
</td>
<td width="50%" valign="top">
<h2>Create a New Account Now!</h2>
<ul>
<li><a href="/user/registration">User Registration</a></li>
</ul>
</td>
</tr>
</table>

@@ registration.html.ep
% layout 'default';
<table width="100%" cellspacing="0">
<tr>
<td width="80%">
<h2>Create a new user account</h2>
<form method="POST">
    <p><label>Name:<br>
    <input type="text" name="name" size="40" /></label></p>
    <p><label>E-mail:<br>
    <input type="text" name="email" size="40" /></label></p>
    <p><label>Password:<br>
    <input type="password" name="password" size="20" /></label></p>
    <input type="submit" value="Save" class="theme-button" />&nbsp;<input type="reset" value="Clear" class="theme-button" />
</form>
</td>
<td width="20%" valign="top">
<!--h2>Rapid Menu</h2>
<ul>
<li><a href="/task/list">List all tasks</a></li>
</ul-->
</td>
</tr>
</table>

@@ dashboard.html.ep
% layout 'default';
<table id="user-infor" width="100%" cellspacing="0">
<tr>
<td width="5%"><img src="https://secure.gravatar.com/avatar/2c0746836fdbfb32bd77af072ad56db9?s=140&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png" alt="Profile Photo" id="avatar" width="48" height="48" /></td>
<td valign="top"><h1><%= session 'name' %>&nbsp;</h1>
<small><a href="mailto:<%= Model::User->load( session 'id' )->email %>"><%= Model::User->load( session 'id' )->email %></a>&nbsp;[<a href="/user/edit">Edit Profile</a>]</small>
</td>
</tr>
</table>
<br>
<table width="100%" cellspacing="0">
<tr>
<td width="60%" valign="top">
<h2>Latest Tasks</h2>
% foreach my $task ( Model::Task->select( 'WHERE author = ? ORDER BY id DESC LIMIT 25', session 'id' ) ) {    
    <div class="alert-task">
        <h3><a href="/task/view/<%= $task->id %>"><%= $task->title %> at 10/09/2011 12:00</a></h3>
        <small>created by <a href="/user/view/<%= Model::User->load( $task->assigned )->id %>"><%= Model::User->load( $task->assigned )->name  %></a></small>
    </div>
% }
<br>
<div style="text-align:center;">
    <a href="/task/list" class="link-button">See More Tasks</a>
</div>
</td>
<td width="20%" valign="top">
<h2>Latest Documents</h2>
<div style="width:90%;max-height:62px;min-height:48px;background-image:url(/doc.png);background-repeat:no-repeat;background-position:0 0;padding-left:48px;padding-top:10px;font-size:10px;text-align:left;">
<strong>Arquivo:</strong>Teste do amor<br> created by <a href="#">dvinciguerra</a> </div>
<div style="width:90%;max-height:62px;min-height:48px;margin:5px;background-image:url(/doc.png);background-repeat:no-repeat;background-position:0 0;padding-left:48px;padding-top:10px;font-size:10px;text-align:left;">
<strong>Arquivo:</strong>Teste do amor<br> created by <a href="#">dvinciguerra</a> </div>
<div style="width:90%;max-height:62px;min-height:48px;margin:5px;background-image:url(/doc.png);background-repeat:no-repeat;background-position:0 0;padding-left:48px;padding-top:10px;font-size:10px;text-align:left;">
<strong>Arquivo:</strong>Teste do amor<br> created by <a href="#">dvinciguerra</a> </div>
<p><small><a href="#">See More</a></small>&nbsp;</p>
</td>
<td width="20%" valign="top">
<h2>Activities</h2>
<div class="alert-activity">
    <strong>Lorem ipsum dolor sit amet</strong><br>
    <small>created by <strong>dvinciguerra</strong> at 11/05/2011</small>
</div>
<div class="alert-activity">
    <strong>Lorem ipsum dolor sit amet</strong><br>
    <small>created by <strong>dvinciguerra</strong> at 11/05/2011</small>
</div>
<div class="alert-activity">
    <strong>Lorem ipsum dolor sit amet</strong><br>
    <small>created by <strong>dvinciguerra</strong> at 11/05/2011</small>
</div>
<div class="alert-activity">
    <strong>Lorem ipsum dolor sit amet</strong><br>
    <small>created by <strong>dvinciguerra</strong> at 11/05/2011</small>
</div>
</td>
</tr>
</table>

@@ userview.html.ep
% layout 'default';
<table id="user-infor" width="100%" cellspacing="0">
<tr>
<td width="5%"><img src="https://secure.gravatar.com/avatar/2c0746836fdbfb32bd77af072ad56db9?s=140&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png" alt="Profile Photo" id="avatar" width="48" height="48" /></td>
<td valign="top"><h1><%= session 'name' %>&nbsp;</h1>
<small><a href="mailto:<%= $user->email %>"><%= $user->email %></a>&nbsp;
% if( $user->id eq session 'id') {
    [<a href="/user/edit">Edit Profile</a>]
% }
</small>
</td>
</tr>
</table>
<br>
<table width="100%" cellspacing="0">
<tr>
<td width="60%" valign="top">
<h2>User Informations</h2>
    <div class="alert-task">
        <p><h3>Company</h3>
        <small>Bivee</small></p>
        <p><h3>Web Site</h3>
        <small><a href="#">www.bivee.com.br</a></small></p>
        <p><h3>Bio</h3>
        <small>
        asdsadasd sadasd asd adaasdasdsa d ad sadsadasda das dasd
         asdsadasd asdadasd asda sdas dsa dsa da dadadsdadas dad
         asdadasdasdasd asd asdasd sadasdsadadas da
        </small></p>
    </div>
<br>
<a href="javascript:void(0);" class="link-button" onclick="history.back(-1);">Go Back</a>
</td>
<td width="40%" valign="top">
<h2>Activities</h2>
<div class="alert-activity">
    <strong>Lorem ipsum dolor sit amet</strong><br>
    <small>created by <strong>dvinciguerra</strong> at 11/05/2011</small>
</div>
<div class="alert-activity">
    <strong>Lorem ipsum dolor sit amet</strong><br>
    <small>created by <strong>dvinciguerra</strong> at 11/05/2011</small>
</div>
<div class="alert-activity">
    <strong>Lorem ipsum dolor sit amet</strong><br>
    <small>created by <strong>dvinciguerra</strong> at 11/05/2011</small>
</div>
<div class="alert-activity">
    <strong>Lorem ipsum dolor sit amet</strong><br>
    <small>created by <strong>dvinciguerra</strong> at 11/05/2011</small>
</div>
</td>
</tr>
</table>

@@ taskform.html.ep
% layout 'default';
<table width="100%" cellspacing="0">
<tr>
<td width="80%">
<h2>Create a new task</h2>
<form method="POST">
    <p><label>Title:<br>
    <input type="text" name="title" size="60" /></label></p>
    <p><label>Description:<br>
    <textarea name="description" rows="6" cols="60"></textarea></label></p>
    <table>
    <tr>
    <td>
    <label>Assigned to:<br>
    <select name="assigned">
% foreach my $u ( Model::User->select ) {
        <option value="<%= $u->id %>"><%= $u->name %></option>
% }
    </select></label>
    </td>
    <td>
    <label>Status:<br>
    <select name="status">
% foreach my $i ( sort keys %$status ) {
    <option value="<%= $i %>"><%= $status->{$i} %></option>
% }    
    </select></label>
    </td>
    <td>
    <label>Type:<br>
    <select name="type">
% foreach my $t ( sort keys %$type  ) {
        <option value="<%= $t %>"><%= $type->{$t} %></option>
% }        
    </select></label>
    </td>
    <td>
    <label>Complexibility:<br>
    <select name="complexibility">
% foreach my $c ( sort keys %$complex  ) {
        <option value="<%= $c %>"><%= $complex->{$c} %></option>
% }        
    </select></label>
    </td>
    </tr>
    </table>
    <p><label>Time estimated:<br>
    <input type="text" name="estimated" size="20" /></label>&nbsp;<small>Ex.: 1d(day) 2m(min) 3h(hours)</small></p>
    <p><label>Tags:<br>
    <input type="text" name="tags" size="40" /></label>&nbsp;<small>Separe tags by comma.</small></p>
    <p><label><input type="checkbox" name="notify" value="1" checked="checked"/>&nbsp;Send notification?</label></p>
    <input type="submit" value="Save" class="theme-button" />&nbsp;<input type="reset" value="Clear" class="theme-button" />
</form>
</td>
<td width="20%" valign="top">
<h2>Rapid Menu</h2>
<ul>
<li><a href="/task/list">List all tasks</a></li>
</ul>
</td>
</tr>
</table>

@@ tasklist.html.ep
% layout 'default';
<table width="100%" cellspacing="0">
<tr>
<td width="80%">
<form method="POST">
    <h2>Task List - What do you want to see?</h2>
    <p><input name="search" style="width:400px;height:22px;padding:5px 10px;border:solid 1px #999;"></p>
    <table width="600px" cellspacing="0">
    <tr>
    <td><select /></td>
    <td><select /></td>
    <td><select /></td>
    <td><select /></td>
    </tr>
    </table>
    <br>
    <h2>All Tasks Listing</h2>
    <br>
% foreach my $task ( Model::Task->select( 'WHERE author = ? ORDER BY id DESC LIMIT 25', session 'id' ) ) {    
    <div class="alert-task">
        <h3 style="padding:0px;margin:0px;line-height:20px;"><a href="/task/view/<%= $task->id %>"><%= $task->title %> at 10/09/2011 12:00</a></h3>
        <small>created by <a href="/user/view/<%= Model::User->load( $task->assigned )->id %>"><%= Model::User->load( $task->assigned )->name  %></a></small>
    </div>
% }     
    <br>
    <p>
    <!-- a href="">1</a>&nbsp;<a href="">2</a>&nbsp;<a href="">3</a>&nbsp;<a href="">4</a //-->&nbsp;</p>
    <input type="button" value="Back" class="theme-button" onclick="history.back(-1);" />
</form>
</td>
<td width="20%" valign="top">
<h2>Rapid Menu</h2>
<ul>
<li><a href="/task/form">Create new tasks</a></li>
<li><a href="/task/form">Create new documents</a></li>
</ul>
<br>
<h2>Tag Cloud</h2>
</td>
</tr>
</table>

@@ not_found.html.ep
% layout 'default';
<h2>PAGE NOT FOUND MAN!</h2>
The requested page has not been found or can be moved by our magic elfs team.
<p>Please come back later and if our elfs team has not resolved the problem... talk with web applications admin about it. ;)</p>
<input type="button" value="Back" onclick="history.back(-1);" class="theme-button" />

<!-- exception.html.ep
% layout 'default';
<h2>Ooooow man, you found a big shit here!</h2>
Your request is walking about some clouds and passed from time tunel... or simply get an error!
<p>We are checking the problem, then... please come back later and try again. ;)</p>
<input type="button" value="Back" onclick="history.back(-1);" class="theme-button" />
-->

@@ layouts/default.html.ep
<!doctype html>
<html>
    <head>
        <title>Tasklicious - Project Task Manager</title>
        <%= base_tag %>
        <style type="text/css">
            html, body {padding:0px;margin:0px;}
            body {margin:0px;padding:0px;background-color: #eaeaea;font-family: Arial, sans-serif;}
            h1,h2,h3,h4,h5 {font-family: times, "Times New Roman", times-roman, georgia, serif; line-height: 40px; letter-spacing: -1px; color: #444; margin: 0 0 0 0; padding: 0 0 0 0; font-weight: 100;}
            a,a:active {color:#660000;text-decoration:none;}
            a:hover{color:#660000}
            a:visited{color:#660000}
            img{border:0px}
            pre{padding:0.5em;overflow:auto;overflow-y:visible;width:600px;}
            pre.lines{border:0px;padding-right:0.5em;width:50px}
            input[type=text] { border:solid 1px #999;}
            input[type=password] { border:solid 1px #999;}
            textarea { border:solid 1px #999;}
            .theme-button {text-align:center;color: #333;padding:10px;font-weight:bold;min-width:125px;}
            _body {min-height:100%;height:auto !important;height:100%;margin:0 auto -6em;}
            #header {width:100%;color:#fff;height:75px;background-color:#333;}
            #header h2 {font-family:Arial;color:#fff;text-shadow: 2px 2px 2px #000;padding:10px 0px 0px 25px;}
            #menu {background-color:#333;padding:0px 0px 0px 25px;}
            #menu ul {width:900px;margin:0px;padding:0px;list-style:none;}
            _menu ul li {margin:0px;padding:0px;float:left;}
            _menu ul li input[type=text] {border:solid 1px #333;font-size:9px;font-weight:bold;}
            .alert-task {padding:5px;border:solid 1px #ccc;width:90%;background-color:#ccc;margin-bottom:10px;}
            .alert-task h3 {padding:0px;margin:0px;line-height:20px;}
            .alert-activity {color:#333;margin-bottom:10px;}
            .link-button {border:solid 1px #999;background-color:#ccc;padding:3px 10px;font-size:10px;font-weight:bold;}
            #user-infor {border-bottom:solid 1px #ccc;}
            #avatar {border:solid 1px #CCC;padding:2px;}
            #top {float:right;width:300px;padding:5px;20px;text-align:right;font-size:9px;font-weight:bold;}
            #top a {color:#FFF;font-weight:bold;}
            #top a:hover {color:#F00;font-weight:bold;}
            #menu a {color:#fff;font-weight:bold;font-size:12px;text-decoration:none;padding-right:15px;}
            #menu a:hover {color:#FFFF00;}
            #visualization {width:900px;margin-right:auto;margin-left:auto;}
            #content {font-size:small;min-height:450px;margin-left:50px;margin-right:50px;}
            .content {background:#eee;border:2px solid #ccc;width:700px}
            .created, .modified {color:#999;margin-left:10px;font-size:small;font-style:italic;padding-bottom:0.5em}
            .modified {margin:0px}
            .label{text-align:right;vertical-align:top;width:1%}
            .center{text-align:center}
            .error {padding:2em;text-align:center}
            #footer{min-height:75px;color:#fff;background-color:#333;margin:auto;margin-top:20px;font-size:80%;text-align:center;padding:20px;}
            #footer a {color:FFFF00;text-decoration:none;font-weight:bolder;}
            .push {height:6em}
            .clear {clear:both}
        </style>
    </head>
    <body>
    <div id="body">
        <div id="header">
% if (session 'name' ) {        
            <div id="top">
            <%= session 'name' %>, <a href="<%= url_for 'signout' %>">Logout</a>
            </div>
% }            
            <h2>Tasklicious - Simple Task Manager</h2>
% if (session 'name' ) {
            <div id="menu">
                <a href="/">Dashboard</a>
                <a href="/task/form">Tasks</a>
                <a href="/doc/form">Documents</a>
                <a href="#">Search</a>
                <a href="#">About</a>
                <a href="#">Help</a>
            </div>
% }            
        </div>
        <br>
        <div id="content">
        <%== content %>
        </div>
    </div>
    <div id="footer">
        <p>
        <strong>(c) 2011 Bivee. All rights reserveds.</strong><br>
        <img src="/perl-powered.png" alt="Perl.Org" />
        </p>
    </div>
    </body>
</html>

@@ perl-powered.png (base64)
R0lGODlhUAAPAPcAAAAAAGZmZk5dhP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAAUAAPAAAI0QADCBxIsKDBgwgTKlzIcOCAhxAjSpxIsaLFixgzCszIEaKAjyBDihxJsqTJkAM2duR4sqXLlyBTBljJEqbNmzFVPgTAEyJPADt77pwo0mPMATGTCjBqdOnDj01zzvQ5dABQqlarRiwKtevSrkiRflUqVqxXs1B1WhW69upPrFtRPj0LdizTuU7LepUa8SrcrH79Rh1Ltq7epGbRHub7t21Vt2zREj6KkjDTs3MHL1VLsyLOzzBldsYIuvRJ0aMtml49EnXq17BpNpxNu7ZtgwEBADs=

@@ doc.png (base64)
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

