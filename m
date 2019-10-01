From: Doug Oucharek <dougso@me.com>
Date: Tue, 1 Oct 2019 09:01:40 -0700
Subject: [lustre-devel] client-server wire protocol
In-Reply-To: <CAKSyJXdF6m5D0w5oFpyEFsTK_0PzJn2-cNsV3QZbH9UrYOtVTQ@mail.gmail.com>
References: <CAKSyJXdF6m5D0w5oFpyEFsTK_0PzJn2-cNsV3QZbH9UrYOtVTQ@mail.gmail.com>
Message-ID: <F4CB592F-6B86-4E87-94A7-DBB067C33910@me.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The best way to learn/understand the protocol is to look at and use the Lustre/LNet dissector for Wireshark.  It was pushed up into the Wireshark project in this commit: https://code.wireshark.org/review/gitweb?p=wireshark.git;a=commit;h=958374f352c0d1c238355a6434e0222e754f43f1 <https://code.wireshark.org/review/gitweb?p=wireshark.git;a=commit;h=958374f352c0d1c238355a6434e0222e754f43f1>.

Doug


> On Sep 28, 2019, at 1:35 PM, Bradley C. Kuszmaul <kuszmaul@gmail.com> wrote:
> 
> Is there a well-defined client-server wire protocol so that one could imagine building a different client or a different server that would interact with lustre?
> 
> I took a quick look through the lustre sources and documentation, but didn't find it.
> 
> -Bradley
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191001/432ba290/attachment.html>
