#!/usr/bin/perl -w

use strict;

################# INSTALL ##################

ack();       # A better grep command.
oh_my_zsh(); # Enhances zsh (requires zsh shell installed).

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
# The first parameter in each line is the name of the configuration file
# (i.e. 'bashrc' is $HOME/.bashrc)
# 
# The second parameter is the path inside dotfiles folder where the final
# configuration file or folder will reside
# (i.e. 'shell/bash' is $HOME/dotfiles/shell/bash)
# 
# Therefore, 'bashrc shell/bash' creates symbolic link $HOME/.bashrc pointing
# to $HOME/dotfiles/shell/bash/bashrc
# 'vim vim' links $HOME/.vim (folder) to $HOME/dotfiles/vim/vim (folder)
# 'vimrc vim' links $HOME/.vimrc (file) to $HOME/dotfiles/vim/vimrc (file)
# 
# Add new lines or comment the existing ones that you don't need
###
my %paths = qw(
                ackrc others/ack                

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
foreach my $file (keys %paths){
    my $dotfile = '.'.$file;
    if (-l $dotfile){
        $bakdf = 1;
        print "\t> $dotfile already exists, creating back up in $bakdotfiles\n";
        rename($dotfile, $bakdotfiles.'/'.$file) or die "\t--- Cannot rename $dotfile: $!";
    }

    print "\t> Creating symbolic link for $dotfile\n\n";
    my $route = $dotfiles.'/'.$paths{$file}.'/';
    symlink($route.$file, $dotfile) or die "\t--- Cannot symlink $route.$file: $!";
}

(rmdir($bakdotfiles) and print "> Deleted empty directory $bakdotfiles\n\n") if !$bakdf;

print "Finished.\n\n";


############# INSTALL FUNCTIONS #############

sub ack {
    my $ack = $ENV{"HOME"}.'/bin/ack';
    system("curl http://beyondgrep.com/ack-2.04-single-file > $ack && chmod 0755 $ack") == 0 or warn "Failed to install ack: $?";
}
sub oh_my_zsh {
    system("curl -L http://install.ohmyz.sh | sh") == 0 or warn "Failed to install oh-my-zsh: $?";
}

