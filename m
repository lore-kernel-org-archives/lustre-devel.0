From: Degremont, Aurelien <degremoa@amazon.com>
Date: Tue, 1 Sep 2020 12:07:28 +0000
Subject: [lustre-devel] Error checking for llapi_hsm_action_progress().
In-Reply-To: <3df93cf2-1a94-f7bf-e073-29bf0c8c985a@cea.fr>
References: <87pn77qx60.fsf@notabene.neil.brown.name>
 <2659fe05-9cd7-afd3-e1ce-c1726129e354@cea.fr>
 <87mu2aqpnp.fsf@notabene.neil.brown.name>
 <3df93cf2-1a94-f7bf-e073-29bf0c8c985a@cea.fr>
Message-ID: <A658F804-B0E6-4F4E-BFB7-0DC54FFDFAA2@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




I also have access to the sources of a different copytool that uses llapi_hsm_action_progress() as a heartbeat (offset=0, length=0).



This should still be supported, this is a feature. Copytool are considered stale if no progress is received for a while. Copytools which are not making any progress (waiting for a tape to be mounted by example) are supposed to send progress for length=0 to avoid timeout.



Aur?lien
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200901/c1df6e4e/attachment.html>
