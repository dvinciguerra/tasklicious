#!/usr/bin/env perl

# (c) 2011 Daniel Vinciguerra

package Model;

use ORLite {
	file => 'tasklicious.db',
};



package main;

use Mojolicious::Lite;

get '/' => sub {
    my $self = shift;

	$self->stash( message => '' );
    $self->render('index');
};

post '/' => sub {
	my $self = shift;

	$self->stash( message => 'Username or password invalid!' );

	my @list = Model::User->select('where email = ? and password = ?', 
			$self->param('username'), $self->param('password'));

	if (scalar @list > 0) {
		$self->session( user => $list[0] );
		$self->redirect_to('/profile');
	} 

	$self->render('index');
};

# check if user is authenticated
ladder sub {
	return 1 if $_[0]->session('user');
	shift->redirect_to('/') and return;
};


get '/profile' => sub {
	my $self = shift;

	$self->render('profile');
};

get '/signout' => sub {
	my $self = shift;
	
	$self->session( expires => 1 );
	$self->redirect_to('/') and return;
};

app->start;
__DATA__

@@ index.html.ep
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

@@ profile.html.ep
% layout 'default';
<h2>Profile</h2>
<div style="text-align: right; background: lightgray; border: solid 1px #999;">Bem vindo <%= (session 'user')->name %>, <a href="/signout">Logout</a>&nbsp;</div>
<br />
<fieldset>
	<legend>Add New Task</legend>
	<form method="POST">
		<table>
			<tr>
				<td><label>Project:</label></td>
				<td>
					<select>
						<option>Select a project...</option>
					</select>&nbsp;or&nbsp;<a href="#">add a new one</a>
				</td>
			</tr>
			<tr>
				<td>
					<label>Description: </label>
				</td>
				<td>
					<input type="text" name="description" size="100" />
				</td>
			</tr>	
			<tr>
				<td>
					<input type="submit" value="Save" />
				</td>
				<td></td>
			</tr>	
	</form>
</fieldset>

@@ layouts/default.html.ep
<!doctype html><html>
    <head>
        <title>Tasklicious - A Simple Mojo Task List</title>
        <%= base_tag %>
    </head>
    <body><%= content %></body>
</html>
