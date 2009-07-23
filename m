From: Alexey Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Thu, 23 Jul 2009 23:50:12 +0300
Subject: [Lustre-devel] Mac OS and Windows clients
In-Reply-To: <689C4F2B-8759-4B61-B2ED-39BCC194608C@swedisk.se>
References: <689C4F2B-8759-4B61-B2ED-39BCC194608C@swedisk.se>
Message-ID: <1248382212.21455.5.camel@berloga.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Tuve
On Thu, 2009-07-23 at 10:00 +0200, Tuve Nordius wrote:
> Hi
> 

> I have chosen the FreeBSD port of lustre (http://lustre.sev.net.ua/)  
> as a starting point for liblustre and the source tree also contains  
> some kind of fuse client, but i suspect this port is based on lustre  
> 1.6 ?
Isn't. this based on HEAD branch which checkouted ~4 month ago. When i
will have time, i will be update to last HEAD sources. 
Work on FreeBSD client is stoped to wait some work from CLIO and libcfs
cleanups, which need to make Solaris port.


-- 
Alexey Lyashkov <Alexey.Lyashkov@Sun.COM>
Sun Microsystems
