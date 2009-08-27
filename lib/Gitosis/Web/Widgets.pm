package Gitosis::Web::Widgets;
use Moose;
use MooseX::AttributeHelpers;
use JSON::XS;
use JavaScript::Minifier;
use CSS::Minifier;

has app => ( is => 'ro', );

has widgets => (
    metaclass  => 'Collection::Array',
    isa        => 'ArrayRef[HashRef]',
    is         => 'ro',
    auto_deref => 1,
    lazy_build => 1,
    provides   => { push => 'add_widget', }
);
sub _build_widgets { [] }

sub widget_js {
    my ($self) = @_;
    my $js = '';
    foreach my $widget ( @{ $self->widgets } ) {
        $js .= sprintf(
            q{Widgets['%s'] = new %s($('%s'), %s);},
            $widget->{id}, $widget->{class}, $widget->{id},
            encode_json( $widget->{args} || {} ),
        );
    }
    $js = "var Widgets = {}; window.addEvent('domready', function() { $js });";
    warn "JS Init: $js\n";
    return $js;
}

sub BUILD {
    my $self = shift;
    warn "Building resources";
    my %resources = (
        "/static/js/gitosisweb.js" => [
            qw(
              /static/js/mootools-1.2.1-core-compressed.js
              /static/js/mootools-1.2-more-compressed_full.js
              /static/js/clientcide-trunk-596.compressed.js
              /static/js/textboxlist-compressed.js
              /static/js/facebook-list.js
              /static/js/common.js
              )
        ],
    );
    foreach my $filename ( keys %resources ) {
        my $out = '';
        foreach my $input ( @{ $resources{$filename} } ) {
            local $/;
            open my $fh, $self->app->path_to( 'root', $input )
              or die "Can't read file $input: $!";
            $out .= <$fh>;
            close $fh;
        }
        $filename = $self->app->path_to( 'root', $filename );
        open my $outfh, ">$filename"
          or die "Can't open $filename for write: $!";
        if (0) {
            print $outfh $out;
        }
        else {
            if ( $filename =~ /\.js$/ ) {
                JavaScript::Minifier::minify(
                    input   => $out,
                    outfile => $outfh
                );
            }
            elsif ( $filename =~ /\.css$/ ) {
                CSS::Minifier::minify( input => $out, outfile => $outfh );
            }
            else {
                print $outfh $out;
            }
        }
        close $outfh;
    }
}

no Moose;
1;
__END__
