From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Sun, 17 Feb 2008 13:27:05 +0200
Subject: [Lustre-devel] Global generic database
In-Reply-To: <20080216074046.GD3029@webber.adilger.int>
References: <47B335B6.5010703@sun.com>
	<200802152050.28398.alexander.zarochentsev@sun.com>
	<20080216074046.GD3029@webber.adilger.int>
Message-ID: <1203247625.2203.23.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, 2008-02-16 at 00:40 -0700, Andreas Dilger wrote:
> 
> There won't immediately be a /proc replacement for uOSS.  Instead,
> there
> will be a new "lctl {get,set}_param" command that reads/writes the
> same proc entries.  At some later time we will make a .lustre/proc
> directory which will allow access to the files currently in /proc,
> possibly also allowing access to /proc values on all lustre nodes.
> That hasn't been designed yet, but would definitely be convenient. 
I think we can put all parameters into sysctl tree and write simple
wraper for userland tools. 
Which add functions for register/list/access to sysctl node.

-- 
Alex Lyashkov <Alexey.lyashkov@sun.com>
Lustre Group, Sun Microsystems
