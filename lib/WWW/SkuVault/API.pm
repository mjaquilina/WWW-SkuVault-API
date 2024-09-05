#!/usr/bin/perl

package WWW::SkuVault::API;

use strict;
use warnings;

use Carp;
use HTTP::Request::Common qw(POST);
use JSON;
use LWP::UserAgent;
use Time::HiRes;

our $VERSION = '0.01';

=head1 NAME

WWW::SkuVault::API - Unofficial Perl interface to the SkuVault WMS API

=head1 DESCRIPTION

This module provides an unofficial Perl interface to the SkuVault WMS API

=head1 METHODS

=head2 new

Returns a new WWW::SkuVault::API object. Takes the following parameters as a hash:

=over 4

=item * B<username>

Your SkuVault username/email address

=item * B<password>

Your SkuVault password

=back

=cut

sub new
{
    my ($class, %params) = @_;

    my $agent = LWP::UserAgent->new;

    my $self = {};

    $self->{lwp}      = $agent;
    $self->{username} = $params{username};
    $self->{password} = $params{password};

    die "Credentials not provided"
        unless $self->{username} and $self->{password};

    bless $self, $class;
    return $self;
}

=head2 authenticate

Authenticates to the SkuVault gettokens endpoint and exchanges your username/password for API tokens.

The module will do this automatically as needed when you make api calls with api_call()

=cut

sub authenticate
{
    my ($self) = @_;

    return 1 if $self->{tenant_token} and $self->{user_token};

    my $r = $self->api_call( 'gettokens', {
        Email    => $self->{username},
        Password => $self->{password},
    });

    return 0 unless $r->{TenantToken} and $r->{UserToken};

    $self->{tenant_token} = $r->{TenantToken};
    $self->{user_token}   = $r->{UserToken};

    return 1;
}

=head2 api_call

Makes a SkuVault API call.

Automatically authenticates and adds the requisite TenantToken and ClientToken - no need to add these with every call.

=cut

sub api_call
{
    my ($self, $path, $params) = @_;

    unless ($path eq 'gettokens')
    {
        $self->authenticate or die "Failed to authenticate";
        $params->{TenantToken} = $self->{tenant_token};
        $params->{UserToken}   = $self->{user_token};
    }

    my $url_base     = "https://app.skuvault.com/api/";
    my $url          = "$url_base$path";
    my $json_params  = encode_json( $params || {} );
    my $http_request = POST(
        $url,
        Content_Type => 'application/json',
        Accept       => 'application/json',
        Content      => $json_params,
    );

    my $response = $self->{lwp}->request($http_request);

    croak "No response content" unless $response->decoded_content;

    my $decoded_content = $response->decoded_content;
       $decoded_content =~ s/[^[:print:]\r\n]//g;

    return JSON->new->decode($decoded_content);
}

=head1 DEPENDENCIES

L<HTTP::Request::Common>, L<JSON>, L<LWP::UserAgent>, L<Time::HiRes>

=head1 DISCLAIMER

The author of this module is not affiliated with SkuVault. It is provided as a courtesy to other users of the SkuVault product.

=head1 LICENSE

This code is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Michael Aquilina <aquilina@cpan.org>

=cut

1;

