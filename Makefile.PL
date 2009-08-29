use inc::Module::Install;

name 'Gitosis-Web';
all_from 'lib/Gitosis/Web.pm';

requires 'Reaction'        => '0.002000';
requires 'Gitosis::Config' => '0.0.4';
requires 'Git::Wrapper'    => '0.007';
requires 'YAML';    # This should reflect the config file format you've chosen
                    # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
