From: Andreas Dilger <adilger@sun.com>
Date: Wed, 25 Jun 2008 13:52:25 -0600
Subject: [Lustre-devel] Unsafe directory modes in lustre-source RPMs
In-Reply-To: <486065C6.7020302@psc.edu>
References: <486065C6.7020302@psc.edu>
Message-ID: <20080625195225.GZ6239@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 23, 2008  23:11 -0400, Benjamin Bennett wrote:
> lustre.spec uses 'make distdir ...' to setup the source tree which will  
> be packaged into the lustre-source rpm.
>
> Automake sets all directories in the distdir tree to mode 777  
> (world-writable, search for "brain-dead tar" in  
> /usr/share/automake-1.7/am/distdir.am).
>
> These modes are kept in rpm packaging, and once the rpm is installed  
> /usr/src/lustre-${version} and its descendant directories will be mode  
> 777 (world-writable).
>
> This can be seen in the release rpms, and those generated from cvs, with  
> a command such as:
>  $ rpm -qlp --dump lustre-source.rpm | \
>    awk '{if ($5 ~ "^04") print $5,$1}'
>
>
> This is obviously less than ideal for any system with unprivileged  
> users.  I've added a find setting the directory modes to 755 just after  
> the make distdir (see patch).  Please let me know if there's any reason  
> this can't be committed.

Thanks for the patch - I filed this as bug 16180 and it should be fixed
for the next release.  It does seem like a bug in automake, because even
with "brain-dead tar" it should be possible to write with user permission
without needing world-write access, because the directory will be owned
by the user extracting the tarball unless it is root, and in that case
root can write to the directory regardless of the mode.

> --- lustre.spec.in	21 May 2008 00:55:39 -0000	1.9
> +++ lustre.spec.in	24 Jun 2008 02:34:50 -0000
> @@ -124,6 +124,7 @@
>  make distdir distdir=lustre-source/lustre-%{version}
> +find lustre-source/lustre-%{version} -type d -exec chmod 755 {} \;

I've changed the patch slightly to use "chmod go-w", and to do this
for all files.  There isn't really any reason why any files in the source
tarball should be world writable.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
