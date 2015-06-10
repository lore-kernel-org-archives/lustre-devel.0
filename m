From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 10 Jun 2015 06:58:02 +0000
Subject: [lustre-devel] OBD_CONNECT_* flags
In-Reply-To: <55774CE2.30107@cray.com>
References: <55774CE2.30107@cray.com>
Message-ID: <D19D2F08.F62A2%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/06/09, 2:30 PM, "Patrick Farrell" <paf@cray.com> wrote:
>Hopefully a fairly quick question...  I'm adding a new feature (lock
>ahead) and would like to use an OBD_CONNECT flag to verify it's
>supported on the server.  I took a quick stab at adding one, but I'm
>getting lost in the details of how the flags are set and exchanged.
>
>Essentially, I would like the client and server (OSS in this case) to
>both have a particular OBD_CONNECT flag or the client will return
>-EOPNOTSUPP when the feature (an ioctl) is invoked.
>So: Is an OBD_CONNECT flag the right way to do this?
>If so, could anyone give a brief explanation of how that works, or an
>example to build off of?

The client sets the OBD_CONNECT flags for features it supports before
connection to the MDS or OSS (or MGS, but we'll leave that out for now).
The server replies with the subset of those flags that it supports,
masking the client flags with either the MDS_CONNECT_SUPPORTED or
OST_CONNECT_SUPPORTED mask, depending on the service type.  The resulting
set of flags are features that both the client and server understand.
Definitely using OBD_CONNECT flags is the intended way to do this.

If this feature only needs to be understood by the OSC and OST, then you
are done - the connect flags are stored for each connection.  If the llite
layer needs to be aware of the feature then this is a bit more complex
because the client->OST connections are async and the flags aren't set
until the connection is completed.  That is fine for checking features as
needed during runtime on a particular OST, but not possible if you would
need to refuse the mount because of some missing server feature (which I
don't think is relevant for your use case).

In theory, the OBD_CONNECT flags could be different on a per-OST basis if
the OSTs were just being upgraded, but practically this is not the case.
For lockahead this seems manageable, since this is just an advisory
feature, so it would be OK if the lockahead requests weren't executed for
some OSTs.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
