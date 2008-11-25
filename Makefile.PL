use inc::Module::Install;

name 'Gitosis-Web';
all_from 'lib/Gitosis/Web.pm';

requires 'Catalyst::Runtime' => '5.7014';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Plugin::I18N';
requires 'Catalyst::Plugin::Browser';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Authentication::Credential::OpenID';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Action::REST';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Model::File';
requires 'Catalyst::View::TT::Alloy';
requires 'Template::Alloy';
requires 'DateTime::TimeZone';
requires 'Gitosis::Config' => '0.0.4';
requires 'YAML';    # This should reflect the config file format you've chosen
                    # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
