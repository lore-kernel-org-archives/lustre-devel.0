From: Indivar Nair <indivar.nair@techterra.in>
Date: Sat, 11 Feb 2012 21:31:43 +0530
Subject: [Lustre-devel] MDS RAM Calculation
In-Reply-To: <CALuPYL0aBcqCkMHx0++De2cKEKARyDu+=K9mrvdxjb1ShgevzQ@mail.gmail.com>
References: <CALuPYL0aBcqCkMHx0++De2cKEKARyDu+=K9mrvdxjb1ShgevzQ@mail.gmail.com>
Message-ID: <CALuPYL1GihOVLDTKuzOxMbqUqmHWmZLpjcQPzFSvHQKDvzFOyg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi ...,

Posted this on the community forum, but haven't got any reply yet.
Kindly help.

We are having trouble with the MDS in our setup. It runs out of memory when
we do large searches on the storage.

*The Setup:
*
We have a Lustre Setup with 2 MDS Servers, replicated using DRBD and 4 OSS
Nodes.
The total storage capacity is aroung 18TB.
We are using Lustre 2.0.0.1.

We have -
- 30 Lustre Clients (CentOS 6)
- 4 Samba Gateway Servers
    - around 120 - 130 Users connect through the Samba Gateway

Both the MDS Servers have -

- 2 x 4 Core Intel CPUs
- 12Gb RAM

The DRBD replication happens over an Infinband Link.

*The Issue:*

We have around *5.5Million files* in the storage. As such everything works
fine during normal operations.
But there are times when we need to search the whole storage, like for
taking backup of recently changed files, and this is when the MDS crashes
giving OOM errors. Any such operation where a *single client side
process*tries to search the whole storage, causes this OOM problem.

1. Is there any setting that could prevent this?
    Since the same files are not accessed frequently, we don't require
extensive caching.
    Is there anyway we can optimize the RAM utilization accordingly?

    If not -
2. Overtime we see the number of files growing from 5.5Million to
7.5Million, but I would like to size the RAM for 10Million files. Just to
be on the safe side.
    How do I go about calculating the exact RAM requirement?

Do tell me if you need any further information on this.

Thanks and Regards,


Indivar Nair
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120211/b0d60768/attachment.htm>
