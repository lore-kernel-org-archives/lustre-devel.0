From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Wed, 28 May 2008 19:24:01 +0400
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C461688A.5460%peter.braam@sun.com>
References: <18490.63940.619731.992500@gargle.gargle.HOWL>
	<C461688A.5460%peter.braam@sun.com>
Message-ID: <18493.30993.371265.613200@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam writes:
 > 
 > Why do they not need file quota - what if someone wants to control file
 > count?

Idea is that support for the inode quota is not necessary is DMU, as
upper layer can implement it by itself. Compare this with block quotas
that do require support from DMU, because upper layer cannot generally
tell overwrite from new-write.

 > > 

Nikita.

 > 
