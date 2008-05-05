From: Peter Braam <Peter.Braam@Sun.COM>
Date: Mon, 05 May 2008 08:41:19 -0600
Subject: [Lustre-devel] Replication
Message-ID: <C44478AF.3F60%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nathan -

I talked through the design with Nikita.  After he had understood our
constraints and I had understood his issues it all narrowed down to one
important improvement that Nikita suggests:  we must get a fast way to
compute the pathname of a FID.  The scanning and searching I suggested
without an index is not tenable.

We had a couple of suggestions, such as storing parent fid and a name in the
EA, or storing similar information in a large directory file.

Can you connect with Nikita and do this?

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080505/23025d10/attachment.htm>
