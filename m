From: Oleg Drokin <green@whamcloud.com>
Date: Wed, 5 Dec 2012 08:54:40 -0500
Subject: [Lustre-devel] Important changes to libcfs primitives usage.
Message-ID: <6BCDB937-AB0C-44E5-8DD7-AB801A673FDC@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just landed first patch of the series to reduce usage of our libcfs_ wrappers for kernel primitives like libcfs_spin_lock/unlock...
   You can see actual change here: http://review.whamcloud.com/#change,2829

   It's highly likely that plenty of patches will be affected. To make our job easier, there is a
   build/libcfs_cleanup.sed script included, you can run it on all your .c and .h files to make necessary replacements:
   sed -i -f build/libcfs_cleanup.sed3  `find . -name "*.h" -or -name "*.c"`

   Please be also advised that there are more changes like this are coming (timeline is not very clear ATM, we might be able to wait with the rest until
   after feature freeze) and the sed script will be updated accordingly.

Bye,
    Oleg
--
Oleg Drokin
Senior Software Engineer
Whamcloud, Inc.
