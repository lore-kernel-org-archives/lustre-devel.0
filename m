From: Michael Kluge <Michael.Kluge@tu-dresden.de>
Date: Wed, 22 Sep 2010 15:46:34 +0200
Subject: [Lustre-devel] Lustre RPC visualization
In-Reply-To: <C671351E-110C-4D2C-B216-4E8BE23A943A@oracle.com>
References: <000c01cae6ee$1d4693d0$57d3bb70$%barton@oracle.com>
	<4BD8E021.7050302@oracle.com> <4BD90FB9.5030702@tu-dresden.de>
	<4BD9CF75.8030204@oracle.com> <4BDE8C3C.2050505@tu-dresden.de>
	<699F57EF-52E6-41D1-A04B-3C39D469D133@oracle.com>
	<4BDF1199.2030007@tu-dresden.de> <4BDF1CC7.5020502@oracle.com>
	<4BDF24BC.9050701@tu-dresden.de> <4BDF2999.2000207@oracle.com>
	<4BEFBB07.4030403@tu-dresden.de> <1274788995.2261.110.camel@radar>
	<4BFC7177.9000808@oracle.com> <1275058473.21591.14.camel@radar>
	<4BFFA456.7030502@oracle.com>
	<C671351E-110C-4D2C-B216-4E8BE23A943A@oracle.com>
Message-ID: <1285163194.2244.416.camel@radar>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Robert,

could please sent me the command how to generate such a log? 

lctl debug_daemon start /tmp/$HOSTNAME
sysctl -w lnet.debug=+rpctrace

Still produces some kind of binary format (at least with my 1.8.3) which
looks different from what you sent me.


Regards, Michael

> > Right now I do not have big clusters available to generate the trace.
> > I will see what I can do here.
> 
> If ~600 clients is big enough we could generate that on Hyperion.
> 
> robert
> 
> > 
> > Thanks
> > WangDi
> >> 
> >> 
> >>  
> >>>> 
> >>>>      
> >>>    
> >> 
> >>  ------------------------------------------------------------------------
> >> 
> >> _______________________________________________
> >> Lustre-devel mailing list
> >> Lustre-devel at lists.lustre.org
> >> http://lists.lustre.org/mailman/listinfo/lustre-devel
> >>  
> > 
> 
> 

-- 

Michael Kluge, M.Sc.

Technische Universit?t Dresden
Center for Information Services and
High Performance Computing (ZIH)
D-01062 Dresden
Germany

Contact:
Willersbau, Room A 208
Phone:  (+49) 351 463-34217
Fax:    (+49) 351 463-37773
e-mail: michael.kluge at tu-dresden.de
WWW:    http://www.tu-dresden.de/zih
-------------- next part --------------
A non-text attachment was scrubbed...
Name: smime.p7s
Type: application/x-pkcs7-signature
Size: 5997 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100922/c7d27756/attachment.bin>
