From: Oleg Drokin <green@whamcloud.com>
Date: Wed, 27 Jul 2011 01:02:23 -0400
Subject: [Lustre-devel] open(), getattr(), and negative dentries
In-Reply-To: <4E2888D2.7090201@tacc.utexas.edu>
References: <4E2888D2.7090201@tacc.utexas.edu>
Message-ID: <6A3C39D7-A059-4E1A-B73E-92F84AA2DE7D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jul 21, 2011, at 4:15 PM, John Hammond wrote:

> It appears that stating a non-existent file on Lustre causes a negative
> dentry to be created, while opening it does not.  If I understand
> correctly, this also means that every open of a non-existent file that
> misses the dentry cache causes an RPC to the MDS.  Is there a reason for
> the difference?

Open does not return a parent dir lock back to the client and this is what guards
negative dentries.
So if you do ls -l on the dir, and then do your open (without O_CREATE!)
the negative dentry will be cached because of the pre-existing lock.
In fact is the dir was last modified sufficiently long ago (like several seconds have passed),
even lookup of the dir itself (even done as part of the path lookup to the filename)
would return you the needed lock and negative dentry will be cached.

Bye,
    Oleg
--
Oleg Drokin
Senior Software Engineer
Whamcloud, Inc.
