#!/usr/bin/perl -w
# -----------------------------------------------------------
# Francisco Dios <frandiox@gmail.com> - http://frandiox.com/
# dotfiles.pl
# -----------------------------------------------------------
use strict;

# You can modify GENERAL, INSTALL and PARAMETERS sections to fit your needs.
# Further modifications should not be necessary.

################# GENERAL ##################

### User home path. Default is set to $HOME
my $home = $ENV{"HOME"};
if (substr($home,0,-1) eq '/'){
    chop($home);
}

### Path to dotfiles folder
my $dotfiles = $home."/dotfiles";

################# INSTALL ##################

mkdir($ENV{"HOME"}.'/bin') if (! -d $ENV{"HOME"}.'/bin');

### Comment the line of the program that you don't need to install
ack();          # A better grep command.
oh_my_zsh();    # Enhances zsh (requires zsh shell installed).
vim_vundle();   # Vim plugin manager.

############### PARAMETERS #################

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
print "  Type:    vim +PluginInstall +qall\  nTo install Vim plugins\n\n";


#############################################
############# INSTALL FUNCTIONS #############
#############################################

sub ack {
    my $ack = $ENV{"HOME"}.'/bin/ack';
    print ">> Instaling ack...\n\n";
    system("curl http://beyondgrep.com/ack-2.04-single-file > $ack && chmod 0755 $ack") == 0 or warn "Failed to install ack: $?";
}
sub oh_my_zsh {
    print "\n>> Installing oh-my-zsh...\n\n";
    system("curl -L -k http://install.ohmyz.sh | sh") == 0 or warn "Failed to install oh-my-zsh: $?";
}
sub vim_vundle {
    print "\n>> Installing Vim Vundle...\n";
    mkdir($dotfiles.'/vim/bundle') or warn "--- Cannot mkdir vim/bundle: $!";
    chdir($dotfiles.'/vim/bundle') or warn "--- Cannot chdir to vim/bundle: $!";
    system("git clone https://github.com/gmarik/Vundle.vim.git") == 0 or warn "--- Cannot clone gmarik/Vundle.vim: $!";
}




