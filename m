From: Jianwei Liao <liaotoad@gmail.com>
Date: Wed, 22 Jun 2011 12:52:34 +0900
Subject: [Lustre-devel] MDS recovery
Message-ID: <BANLkTi=SBNhfTz+L6Ly21KdWuhj+1wO+BA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,
I am a new comer to Lustre.
Recently, I have read some documents about Lustre file system and am
interested in MDS recovery.
1) I was wondering that during MDS recovery(resend, and replay etc.), both
the clients who involved in the recovery or the others(who are not involved
in the recovery process) could access the MDS to get the file information or
not.
Simply speaking, during MDS recovery, is the MDS available or not?
2) Compared with non-VBR recovery, how about the time needed for MDS
recovery while using VBR.

Thank you very much.
Best regards,
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110622/9239900b/attachment.htm>
