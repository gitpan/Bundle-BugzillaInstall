package Bundle::BugzillaInstall;

use strict;
use warnings;
use CPAN;
	

our $VERSION = '0.01';

my $httpd_dir;
my $bz_dir = "mozilla/webtools/bugzilla";
my $full_path;
my @Bugzilla_modules_list = ('CGI', 'AppConfig', 'Date::Format','Data::Dumper', 'DBI','DBD::mysql','File::Spec','File::Temp','Template','Text::Wrap',
   'Mail::Mailer','MIME::Base64','MIME::Parser','Storable','GD', 'GD::Graph', 'GD::Graph3d','Chart::Base','GD::Text::Align','XML::Parser',
   'PatchReader','Image::Magick');





# Functions

sub install_Bugzila_modules {
        for ($_){CPAN::Shell->expand('Module',$_)->install}
}

sub install_Testopia_modules {
        for ($_){CPAN::Shell->expand('Module',$_)->install}
}



sub install_testopia {
	print "TBD";
        system ("cvs -d ");
}


sub debug {
	#Remove temp Bugzilla installation
	print "\n***********Debug:***************\nRemoving temp bugzilla installation\n**************************";
	system ("rm -r -f $full_path");
	system ("cp -f /etc/httpd/conf/httpd.conf.bak /etc/httpd/conf/httpd.conf");
}


# Main block
#***********

#Check for Apache process
print "\n\tChecking for Apache process...", `ps -A | grep httpd`  ?  "\t\tOK" : "\t\tFAILED - Please start Apache Web Server";

#Check for MySQL process
print "\n\tChecking for MySQL process...", `ps -A | grep mysqld`  ?   "\t\tOK" : "\tFAILED - Please start MySql Server";

#Check for Sendmail process
print "\n\tChecking for SendMail process...", `ps -A | grep sendmail`  ? "\tOK" : "\tFAILED - Please start Sendmail Server","\n\n";



#Installing bugzilla modules
foreach (@Bugzilla_modules_list) {
        print "\n\t\tInstalling Bugzilla Module $_ --> ";
        install_Bugzila_modules($_);
}


# Checking for HTTP root directory
my $search="DocumentRoot \"";
open (CONF, "/etc/httpd/conf/httpd.conf") || die "couldn't open the Apache config file!";
        my @array=<CONF>;
        close (CONF);
        foreach my $line (@array){
                if ($line =~ /$search/){
                        (my $last,$httpd_dir)=split(/"/,$line);
                }
        }
        print "\t\tApache home directory is ", $httpd_dir;
        print "\n\t\tBugzilla Directory will be ", $httpd_dir,"/",$bz_dir;

$full_path = $httpd_dir . "/" . $bz_dir;

# Update httpd.conf with bugzilla path and restart httpd
my $string = "<Directory $full_path>
  AddHandler cgi-script .cgi
  Options +Indexes +ExecCGI
  DirectoryIndex index.cgi
  AllowOverride Limit
</Directory>";

my $data_file = "/etc/httpd/conf/httpd.conf";
open DATA, ">>$data_file" or die "can't open $data_file $!";
print DATA $string;
print "\n\nRestarting httpd\n";
system ("service httpd restart");


# Change working direstory to HTTP root directory
die "Can't cd to $httpd_dir: $!\n" unless chdir $httpd_dir;
    chdir $httpd_dir or die "Can't cd to $httpd_dir: $!\n";

#Installing bugzilla
print "\nInstall bugzilla from cvs";
        system ("cvs -d :pserver:anonymous\@cvs-mirror.mozilla.org:/cvsroot checkout -rBugzilla_Stable Bugzilla");
        system ("$bz_dir/checksetup.pl --check-modules");

#Updating localconfig file
print "\nUpdate localconfig file";
        $data_file = $full_path ."/" . "localconfig";
        $string = "\$db_pass = 'bugs'\;";
        open DATA, ">>$data_file" or die "can't open $data_file $!";
        print DATA $string;

        print "\n\n************************************************************************************";
        print "\n\tPlease add user bugs with password bugs to mysql database and press enter to continue";
        print "\n\ttype: mysql -p ", "(put admin password)","\tand after login paste to mysql prompt:";
        print "\n\tGRANT SELECT, INSERT,UPDATE, DELETE, INDEX, ALTER, CREATE, LOCK TABLES, CREATE TEMPORARY TABLES, DROP, REFERENCES ON bugs.* TO bugs\@localhost IDENTIFIED BY 'bugs'\;";
        print "\n\n************************************************************************************";
        $_ = <STDIN>;





#Starting bugzilla
system ("$bz_dir/checksetup.pl");
system ("$bz_dir/checksetup.pl");


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Bundle::BugzillaInstall - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Bundle::BugzillaInstall;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Bundle::BugzillaInstall, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Oleg Sher, E<lt>oleg.sher@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Oleg Sher

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
