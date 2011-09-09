#!/usr/bin/env perl

# (c) 2011 Bivee. All rights reserveds.

package Model;

use ORLite {
	file => 'tasklicious.db',
};

package main;

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

# signin action
get '/signin' => { message => '' } => 'signin';
post '/signin' => sub {
	my $self = shift;

	my @list = Model::User->select('where email = ? and password = ?', 
			$self->param('username'), $self->param('password'));

	if (scalar @list > 0) {
		$self->session( user => $list[0]->name );
		$self->redirect_to('/');
        return;
	}

	$self->stash( 
        message => 'Username or password invalid!' 
    );
} => 'signin';

# check if user is authenticated
ladder sub {
	return 1 if $_[0]->session('user');
	shift->redirect_to('/signin') and return;
};

# index action
get '/' => 'dashboard';
post '/' => sub{} => 'dashboard';

# task action
get '/task/form' => sub { 
    my $self = shift;
    $self->stash( 
        task => {}, 
        status => $status, 
        complex => $complex 
    );
} => 'taskform';
post '/task/form' => sub {
    my $self = shift;
} => 'taskform';

get '/task/list' => sub {
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

@@ dashboard.html.ep
% layout 'default';
<h2>Dashboard</h2>
Latest Task

Projects

Notes

Latest Activities

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
    <select name="assigned">
% foreach my $i ( sort keys %$status ) {
    <option value="<%= $i %>"><%= $status->{$i} %></option>
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
    <input type="text" name="estimated" size="20" /></label><small>Ex.: 1d(day) 2m(min) 3h(hours)</small></p>
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
<h2>List all tasks</h2>
<form method="POST">
    <table width="600px" cellspacing="0">
    <tr>
    <td><select /></td>
    <td><select /></td>
    <td><select /></td>
    <td><select /></td>
    </tr>
    </table>
    <br>
    <table width="600px" cellspacing="0">
    <tr>
    <td>ID</td>
    <td>Title</td>
    <td>Created</td>
    <td>Action</td>
    </tr>
    <tr>
    <td>00</td>
    <td>Lorem ipsum dolor sit amet</td>
    <td>00/00/0000</td>
    <td><a href="#">Show Details</a></td>
    </tr>
    <tr>
    <td>00</td>
    <td>Lorem ipsum dolor sit amet</td>
    <td>00/00/0000</td>
    <td><a href="#">Show Details</a></td>
    </tr>
    <tr>
    <td>00</td>
    <td>Lorem ipsum dolor sit amet</td>
    <td>00/00/0000</td>
    <td><a href="#">Show Details</a></td>
    </tr>
    </table>
    <br>
    <p>
    <a href="">1</a>&nbsp;<a href="">2</a>&nbsp;<a href="">3</a>&nbsp;<a href="">4</a>&nbsp;</p>
    <input type="button" value="Back" class="theme-button" onclick="history.back(-1);" />
</form>
</td>
<td width="20%" valign="top">
<h2>Rapid Menu</h2>
<ul>
<li><a href="/task/form">Create new tasks</a></li>
</ul>
</td>
</tr>
</table>

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
            textarea { border:solid 1px #999;}
            .theme-button {color: #333;padding:10px;font-weight:bold;min-width:125px;}
            _body {min-height:100%;height:auto !important;height:100%;margin:0 auto -6em;}
            #header {width:100%;color:#fff;height:75px;background-color:#333;}
            #header h2 {font-family:Arial;color:#fff;text-shadow: 2px 2px 2px #000;padding:10px 0px 0px 25px;}
            #menu {background-color:#333;padding:0px 0px 0px 25px;}
            #menu ul {width:900px;margin:0px;padding:0px;list-style:none;}
            _menu ul li {margin:0px;padding:0px;float:left;}
            _menu ul li input[type=text] {border:solid 1px #333;font-size:9px;font-weight:bold;}
            #top {float:right;width:300px;padding:5px;20px;text-align:right;font-size:9px;font-weight:bold;}
            #top a {color:#FFF;font-weight:bold;}
            #top a:hover {color:#F00;font-weight:bold;}
            #menu a {color:#fff;font-weight:bold;font-size:12px;text-decoration:none;padding-right:15px;}
            #menu a:hover {color:#FFFF00;}
            #visualization {width:900px;margin-right:auto;margin-left:auto;}
            #content {font-size:small;min-height:450px;margin-left:50px;margin-right:auto;}
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
% if (session 'user' ) {        
            <div id="top">
            <%= session 'user' %>, <a href="<%= url_for 'signout' %>">Logout</a>
            </div>
% }            
            <h2>Tasklicious - Simple Task Manager</h2>
% if (session 'user' ) {
            <div id="menu">
                <a href="/">Dashboard</a>
                <a href="/task/form">Tasks</a>
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
        <p>Powered by <a href="http://perl.org">Perl</a>.<br>
        <strong>(c) 2011 Bivee. All rights reserveds.</strong></p>
    </div>
    </body>
</html>
