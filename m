From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 27 Jun 2008 13:24:38 -0600
Subject: [Lustre-devel] [RFC] HLD Review Request: Interoperability at
	server side
In-Reply-To: <48632894.1050204@sun.com>
Message-ID: <C48A9A97.611F%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Really good - well done!  I feel comfortable that this can move ahead.

I just want to ask you to make sure that repeated upgrade - downgrade -
upgrade events (in the case bugs in the new release force the user back to
old) are handled correctly.  I did see a discussion of up and down, but no
explicit mention of repeating that process multiple times.

Regards,

Peter




On 6/25/08 11:26 PM, "Rahul Deshmukh" <Rahul.Deshmukh@Sun.COM> wrote:

> Hi Peter/Eric,
> 
> Please inspect next version of "Interoperability at server side" HLD.
> 
> Thanks,
> Rahul.
> 

-------------- next part --------------
A non-text attachment was scrubbed...
Name: interop_disk_fidea.pdf
Type: application/octet-stream
Size: 121109 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080627/86b98293/attachment.obj>
