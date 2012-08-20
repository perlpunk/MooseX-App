package MooseX::App::Simple;
# ============================================================================«

use 5.010;
use utf8;
use strict;
use warnings;

our $AUTHORITY = 'cpan:MAROS';
our $VERSION = '1.05';

use Moose::Exporter;
use MooseX::App::Exporter qw(app_base option command_short_description command_long_description);
use MooseX::App::Meta::Role::Attribute::Option;
use MooseX::App::Message::Envelope;

my ($IMPORT,$UNIMPORT,$INIT_META) = Moose::Exporter->build_import_methods(
    with_meta           => [ 'app_base', 'option', 'command_short_description', 'command_long_description' ],
    also                => 'Moose',
    install             => [ 'unimport', 'init_meta' ],
);

sub import {
    my ( $class, @plugins ) = @_;
    
    # Get caller
    my ($caller_class) = caller();
    
    # Process plugins
    MooseX::App::Exporter->process_plugins($caller_class,@plugins);
    
    # Call Moose-Exporter generated importer
    return $class->$IMPORT( { into => $caller_class } );
}

sub init_meta {
    my ($class,%args) = @_;
    
    my $for_class       = $args{for_class};
    $args{roles}        = ['MooseX::App::Role::Simple' ];
    $args{metaroles}    = {
        class               => ['MooseX::App::Meta::Role::Class::Base','MooseX::App::Meta::Role::Class::Simple','MooseX::App::Meta::Role::Class::Command'],
    };
    my $meta = MooseX::App::Exporter->process_init_meta(%args);
    
    $for_class->meta->app_commands({ 'self' => $for_class });
    
    return $meta;
}

no Moose;
1;

__END__

=encoding utf8

=head1 NAME

MooseX::App::Simple - Single command applications

=head1 SYNOPSIS

  package MyApp;
  use MooseX::App::Simple qw(Config Color);
 
  option 'my_option' => (
      is            => 'rw',
      isa           => 'Bool',
      documentation => q[Enable this to do fancy stuff],
  );
  
  has 'private' => ( 
      is              => 'rw',
  ); # not exposed
  
  sub run {
      my ($self) = @_;
      # Do something
  }

And then in some simple wrapper script:
 
 #!/usr/bin/env perl
 use MyApp;
 MyApp->new_with_options->run;

=head1 DESCRIPTION

MooseX-App-Simple works basically just as MooseX-App, however it does 
not search for commands and assumes that you have all options defined
in the current class.

Read the L<Tutorial|MooseX::App::Tutorial> for getting started with a simple 
MooseX::App command line application.

=head1 METHODS

=head2 new_with_options

 my $myapp_command = MyApp->new_with_options();

This method reads the command line arguments from the user and tries to create
instantiate the current class with the ARGV-input. If it fails it retuns a 
L<MooseX::App::Message::Envelope> object holding an error message.

You can pass a hash of default params to new_with_command

 MyApp->new_with_options( %default );

=head1 OPTIONS

Same as in L<MooseX::App>

=head1 PLUGINS

Same as in L<MooseX::App>. However plugings adding commands
will not work with MooseX::App::Simple.

=head1 SEE ALSO

Read the L<Tutorial|MooseX::App::Tutorial> for getting started with a simple 
MooseX::App command line application.

L<MooseX::Getopt>

=cut