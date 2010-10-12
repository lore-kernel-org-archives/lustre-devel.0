From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Tue, 12 Oct 2010 13:55:12 -0400
Subject: [Lustre-devel] Query to understand the Lustre request/reply message
Message-ID: <AANLkTikzzrewMtTrpwkWLCJ3soL+HerfSBU6G3KT6O8j@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I want to understand the message encoding and decoding logic in lustre.I am
planning to send a request to the MDS and based on the reply from MDs want
to populate the

   struct lustre_msg *rq_repbuf; /* client only, buf may be bigger than msg
*/
   struct lustre_msg *rq_repmsg;

I am trying this for a simple "Hello" message but not seeing the expected
output.Sometime I even see Kernel Crash.
If you can please give me some insight on the way the Lustre File system
encodes decodes the messages sent accross nodes it would be helpful.

Thanks,
Vilobh
*Graduate Research Associate
Department of Computer Science
The Ohio State University Columbus Ohio*
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101012/1769fe4d/attachment.htm>
