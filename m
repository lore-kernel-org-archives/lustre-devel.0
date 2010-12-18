From: Jay Lan <jlan@sgi.com>
Date: Fri, 17 Dec 2010 16:43:27 -0800
Subject: [Lustre-devel] ldiskfs build problem with rhel5.5
Message-ID: <4D0C03AF.2060800@sgi.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I ran into a problem in building ldiskfs-3.1.4 with 2.6.18-194.3.1.el5 
kernel.
The kernel was patched with kernel patches provided by lustre-1.8.5 and
ldiskfs-3.1.4.

The problem I encountered was that the kernel and kernel-devel rpms
did not provide fs/ext4/*.[ch], which the build process would need.

Is there a kernel patch for this problem?

Regards,
Jay
