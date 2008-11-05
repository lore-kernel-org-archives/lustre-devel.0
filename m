From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Wed, 05 Nov 2008 14:58:10 -0500
Subject: [Lustre-devel] java successfully call the Native functions,
 :-) but there are still some problems like "Lustre mount
 failed:	Invalid argument", when i call 	the  __liblustre_setup_().
In-Reply-To: <a257968a-472f-43bd-93bf-5dfc96d3bd1f@u18g2000pro.googlegroups.com>
References: <bfe9780e-a03e-4e21-916e-44f5a4db8dba@v39g2000pro.googlegroups.com>
	<1225806515.2247.240.camel@brian-laptop>
	<a257968a-472f-43bd-93bf-5dfc96d3bd1f@u18g2000pro.googlegroups.com>
Message-ID: <1225915091.3785.57.camel@pc.interlinx.bc.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2008-11-04 at 19:01 -0800, kcruci wrote:
> 
> I write a test in c which call the function in liblustremkdir.so, and
> gcc it with liblustremkdir.so, the c tests run seccessfuly.

Ahhh.  Good.

> So, my question is that why libsysio cannot catch the "mount" even the
> _sysio_init() and _sysio_lustre_init() has runed when using JNI.

Sorry, I have no idea.  I know nothing at all about developing in Java.
Sounds like this is more a Java question than a Lustre question though.
Maybe there is a different audience you can target that would know more
about Java and external libraries than you will probably find here.

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 197 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20081105/b17f06a6/attachment.pgp>
