#!/usr/bin/perl -w

use strict;

############# PARAMETERS ###############

my $home = $ENV{"HOME"};
if (substr($home,0,-1) eq '/'){
    chop($home);
}

my $dotfiles = $home."/dotfiles";

my %paths = qw(
                bashrc shell/bash
                bash_profile shell/bash
                bash_aliases shell/bash
                
                gitconfig git
                gitignore_global git
                
                i3 i3
                profile shell
                tmux.conf tmux
                vim vim
                vimrc vim
                zshrc shell/zsh
                );

########################################

chdir($home) or die "--- Cannot chdir to $home: ($!)\n";
print "> Entering directory $home\n";

my $bakdotfiles_orig = '.bakdotfiles';
my $bakdotfiles = $bakdotfiles_orig;
if (-d $bakdotfiles){ 
    my $i = 0;
    $bakdotfiles .= $i;
    while (-d $bakdotfiles){
        $i += 1;
        $bakdotfiles = $bakdotfiles_orig.$i;
    }
}
mkdir($bakdotfiles) or die "--- Cannot mkdir $bakdotfiles: $!";
my $bakdf = 0;
print "> Creating directory $bakdotfiles\n\n";

foreach my $file (keys %paths){
    my $dotfile = '.'.$file;
    if (-l $dotfile){
        $bakdf = 1;
        print "> $dotfile already exists, creating back up in $bakdotfiles\n";
        rename($dotfile, $bakdotfiles.'/'.$file) or die "--- Cannot rename $dotfile: $!";
    }

    print "> Creating symbolic link for $dotfile\n\n";
    my $route = $dotfiles.'/'.$paths{$file}.'/';
    symlink($route.$file, $dotfile) or die "--- Cannot symlink $route.$file: $!";
}

(rmdir($bakdotfiles) and print "> Deleted empty directory $bakdotfiles\n\n") if !$bakdf;

print "Finished.\n\n";
