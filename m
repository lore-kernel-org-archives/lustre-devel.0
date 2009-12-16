From: Isaac Huang <He.Huang@Sun.COM>
Date: Tue, 15 Dec 2009 21:48:18 -0500
Subject: [Lustre-devel] client side reply handling
In-Reply-To: <2b20c7140912151801m78871060pd20e5136c105b507@mail.gmail.com>
References: <2b20c7140912090705s47667951w26fe6c95e81f2c8f@mail.gmail.com>
	<3ed212d00912150828u2fc58cf2v541c95989d220a85@mail.gmail.com>
	<2b20c7140912151801m78871060pd20e5136c105b507@mail.gmail.com>
Message-ID: <20091216024818.GA1196@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Dec 15, 2009 at 07:01:33PM -0700, Peter Braam wrote:
>    No - buffers can and probably should (because, for example, re-delivery
>    may leaver buffer state undefined) be unlinked from the match list
>    before passing the buffer up to any other layer.  Portals/LNET
>    certainly can do this.

Hi Peter, LNet does have a MD option to automatically unlink the
buffer once it's been exhausted. Duplicated delivery shouldn't cause any
problem because MD offset is increased locally (i.e. a dup would go
into a different offset), unless the MD has enabled peers to manage
offset remotely, which is now true for PTLRPC reply buffers (because
now early replies and real reply share a same reply buffer).

Isaac
