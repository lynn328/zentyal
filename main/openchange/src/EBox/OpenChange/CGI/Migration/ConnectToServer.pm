# Copyright (C) 2013 Zentyal S.L.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

use strict;
use warnings;

package EBox::OpenChange::CGI::Migration::ConnectToServer;

use base 'EBox::CGI::Base';

use EBox;
use EBox::Global;
use EBox::Gettext;
use EBox::OpenChange::MigrationRPCClient;
use Error qw(:try);

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new('title'    => 'none',
                                  'template' => 'none',
                                  @_);
    bless ($self, $class);
    return $self;
}

sub _process
{
    my ($self) = @_;

    try {
        $self->{json}->{success} = 0;

        $self->_requireParam('server', __('Server'));
        my $server = $self->unsafeParam('server');

        $self->_requireParam('username', __('user name'));
        my $username = $self->unsafeParam('username');

        $self->_requireParam('password', __('password'));
        my $password = $self->unsafeParam('password');

        my $rpc = new EBox::OpenChange::MigrationRPCClient();
        my $request = {
            command => 1,
            address  => $server,
            username => $username,
            password => $password,
        };
        my $response = $rpc->send_command($request);
        if ($response->{code} == 0) {
            $self->{json}->{success} = 1;
        } else {
            $self->{json}->{success} = 0;
            $self->{json}->{mapierror} = $response->{mapierror};
        }
    } otherwise {
        my ($error) = @_;

        $self->{json}->{success} = 0;
        $self->{json}->{error} = qq{$error};
    };
}

1;
