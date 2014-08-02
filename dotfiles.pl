#!/usr/bin/perl -w
# -----------------------------------------------------------
# Francisco Dios <frandiox@gmail.com> - http://frandiox.com/
# dotfiles.pl
# -----------------------------------------------------------
use strict;

# You can modify INSTALL and DOTFILES PARAMETERS sections to fit your needs.
# Further modifications should not be necessary.


################# INSTALL ##################

mkdir($ENV{"HOME"}.'/bin') if (! -d $ENV{"HOME"}.'/bin');

### Comment the line of the program that you don't need to install
print ">> Installing ack...\n\n"; ack();       # A better grep command.
print ">> Installing oh-my-zsh...\n\n"; oh_my_zsh(); # Enhances zsh (requires zsh shell installed).

########### DOTFILES PARAMETERS ############

### User home path. Default is set to $HOME
my $home = $ENV{"HOME"};
if (substr($home,0,-1) eq '/'){
    chop($home);
}

### Path to dotfiles folder
my $dotfiles = $home."/dotfiles";

### Paths to be linked (symbolic link)
# 
# Every path must exist inside dotfiles folder. This creates a symbolic link
# in $HOME pointing to the specific path. The last part of each path also
# specifies the name of the original dotfile (without '.')
#
# Examples:
# 'shell/bash/bashrc'>  $HOME/.bashrc   --->    $HOME/dotfiles/shell/bash/bashrc (file)
# 'vim'>                $HOME/.vim      --->    $HOME/dotfiles/vim (folder)
# 'vim/vimrc'>          $HOME/.vimrc    --->    $HOME/dotfiles/vim/vimrc (file)
#
# Add new lines or remove the existing ones that you don't need
###
my @paths = qw(
                i3
                git/gitconfig
                git/gitignore_global
                others/ack/ackrc
                shell/profile
                shell/bash/bashrc
                shell/bash/bash_aliases
                shell/bash/bash_profile
                shell/zsh/zshrc
                tmux/tmux.conf
                vim
                vim/vimrc
);


############################################
################ DOTFILES ##################
############################################

print "> Entering directory $home\n";
chdir($home) or die "--- Cannot chdir to $home: ($!)\n";

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
print "> Creating directory $bakdotfiles\n\n";
mkdir($bakdotfiles) or die "--- Cannot mkdir $bakdotfiles: $!";

my $bakdf = 0;
foreach my $path (@paths){
    my $file = (split(/\//, $path))[-1];
    my $dotfile = '.'.$file;
    if ((-l $dotfile) or (-e $dotfile)){
        $bakdf = 1;
        print "\t> $dotfile already exists, creating back up in $bakdotfiles\n";
        rename($dotfile, $bakdotfiles.'/'.$file) or die "\t--- Cannot rename $dotfile: $!";
    }

    print "\t> Creating symbolic link for $dotfile\n\n";
    my $route = $dotfiles.'/'.$path;
    symlink($route, $dotfile) or die "\t--- Cannot symlink $route: $!";
}

(rmdir($bakdotfiles) and print "> Deleted empty directory $bakdotfiles\n\n") if !$bakdf;

print "Finished.\n\n";


#############################################
############# INSTALL FUNCTIONS #############
#############################################

sub ack {
    my $ack = $ENV{"HOME"}.'/bin/ack';
    system("curl http://beyondgrep.com/ack-2.04-single-file > $ack && chmod 0755 $ack") == 0 or warn "Failed to install ack: $?";
}
sub oh_my_zsh {
    system("curl -L -k http://install.ohmyz.sh | sh") == 0 or warn "Failed to install oh-my-zsh: $?";
}

