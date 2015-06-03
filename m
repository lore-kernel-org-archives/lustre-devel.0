From: Ned Bass <bass6@llnl.gov>
Date: Wed, 3 Jun 2015 13:57:25 -0700
Subject: [lustre-devel] Lustre and libreadline
In-Reply-To: <556F6341.3070507@cray.com>
References: <556F4825.1050408@cray.com> <20150603185716.GA10033@llnl.gov>
	<556F6341.3070507@cray.com>
Message-ID: <20150603205725.GH10066@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 03, 2015 at 03:27:45PM -0500, Patrick Farrell wrote:
> You say you just install the library and not the utils, but do you
> specifically build without the utils?  Is there some existing config
> option for that?  (Hoping to save myself some grepping...)
> Otherwise, I'll have to add in that option.

There's no such config option, I just manually perform the build steps
after configure. Something like this:

./configure --disable-server --disable-readline
cd lustre/utils
make CC=mpicc liblustreapi.a
<$BQQ_BIN_DIR>/gcc -shared -Wl,-soname,liblustreapi.so.0 -o liblustreapi.so.0 liblustreapi*.o l_ioctl.o kernel_user_comm.o

Kind of a hack, but we don't update it often so I haven't bothered to
add build system support.

Ned
