From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Mon, 17 Dec 2012 12:21:44 -0500
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
	primitives usage.
In-Reply-To: <AE8E737235CD0640B291384BFC2D8A354A3A7348@MX10A.corp.emc.com>
Message-ID: <201212171721.qBHHLiEn023769@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Current the libcfs cleanup is mainly done by replacing kinds of         
>libcfs calls with direct kernel primitives, we can implement the        
>portable layer on other OS with the same name as Linux.  I think        
>the real concern is that on other OS there is possible some kernel      
>primitives have the same name a Linux kernel but with different         
>behavior/parameters, that will cause either compiling broken or running 
>crashing etc.  I don't have the full list of the above intersecting     
>case, but it should be very rare right? We can build a separate patch(  
>which should be small) for those intersecting cases for other OS, and I 
>guess that patch need to be maintained separately.                      

Like I said, I'm fine with that; at least in the MacOS X case I don't
recall any symbol names which overlapped.

>And lustre CLIO is structured that all OS-dependent glue is supposed
>to be handled in the topmost layer (VVP for linux client). For Mac or
>Windows's native client, it is possibly just implement a new thin top
>layer if interests really raised on those platform? This could reduce
>the possibility of the above intersecting cases.

Well, it's only a "thin" layer if your VM system looks exactly like Linux;
otherwise it ain't so thin.  Yeah, I did some of that, but it wasn't
easy.

--Ken
