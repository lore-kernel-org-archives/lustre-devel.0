From: vilobh meshram <meshram.vilobh@gmail.com>
Date: Thu, 5 May 2011 02:57:19 -0400
Subject: [Lustre-devel] Fwd: Question on path name resolution in Lustre
In-Reply-To: <BANLkTimoh3K1NCv_RC1HMdpko4zk=BGTcA@mail.gmail.com>
References: <BANLkTimoh3K1NCv_RC1HMdpko4zk=BGTcA@mail.gmail.com>
Message-ID: <BANLkTik18X7bWw21F8E-wK2wzyG3spLdDA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

---------- Forwarded message ----------
From: vilobh meshram <meshram.vilobh@gmail.com>
Date: Thu, May 5, 2011 at 2:37 AM
Subject: Question on path name resolution in Lustre
To: lustre-discuss <lustre-discuss@lists.lustre.org>,
lusre-devel at lists.lustre.org


Hi,

I have noticed that for file or directory kind of operation in Lustre, the
Lock Manager grabs an EX (Exclusive lock) on the parent directory and then
creates a directory or file inside it.Is there a specific reason behind this
logic or implementation.

e.g. : If we want to create foo.txt in /d1/d2/d3/d4/d5/foo.txt

We grab the lock on /d1
then we grab the lock on /d1/d2
then we grab the lock on /d1/d2/d3
then we grab the lock on /d1/d2/d3/d4
then we grab the lock on /d1/d2/d3/d4/d5
then we create the file.
This is what I have seen in logs.

Is this the correct method followed during first time file access or file
creation ?

If yes then how is the performance when the directory depth is very high ?

If no can you explain me how it happens.

Thanks,
Vilobh
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110505/65724222/attachment.htm>
