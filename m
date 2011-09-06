From: Indivar Nair <indivar.nair@techterra.in>
Date: Tue, 6 Sep 2011 12:03:42 +0530
Subject: [Lustre-devel] Slow Directory Listing
Message-ID: <CALuPYL2nPzJ9QG4GUR+-XFB0ma2UDMk_=54Uv976n+AH=j1tag@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi ...,

I have a lustre storage that stores lots of small files i.e. hundreds to
thousand of 9MB image files.
While normal file access works fine, the directory listing is extremely
slow.
Depending on the number of files in a directory, the listing takes around 5
- 15 secs.

I tried 'ls --color=none' and it worked fine; listed the contents
immediately.

But that doesn't help my cause. I have Samba Gateway Servers, and all users
access the storage through the gateway. Double clicking on directory takes a
long long time to display.

The cluster consist of -
- two DRBD Mirrored MDS Servers (Dell R610s) with 10K RPM disks
- four OSS Nodes (2 Node Cluster (Dell R710s) with a common storage (Dell
MD3200))

The storage consists of 12 x 1TB HDDs on both arrays, in RAID 6
Configuration.

What actually happens when one does a listing like this?
What can I do to make the listing faster?
Could it be an MDS issue?
Some site suggested that this could be caused due to '-o flock' switch. Is
it so?

Kindly Help.
The storage is in Production, and this is causing a lot of issues.

Regards,


Indivar Nair
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110906/a91bc43f/attachment.htm>
