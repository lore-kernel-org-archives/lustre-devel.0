From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Wed, 29 Jul 2009 19:55:31 +0100
Subject: [Lustre-devel] SMP Scalability, MDS, reducing cpu pingpong
In-Reply-To: <31A2D6F1-C723-4EB5-8515-D155FE923C9A@Sun.COM>
References: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
	<002001ca1062$7b526fc0$71f74f40$@com>
	<31A2D6F1-C723-4EB5-8515-D155FE923C9A@Sun.COM>
Message-ID: <1248893731.4563.13.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Qua, 2009-07-29 at 12:01 -0400, Oleg Drokin wrote:
> Yes. If clients are not contending, we have same benefits, but
> this never happens in the real world.
> Creates in a same dir is a contention point on the dir and there is
> no point in scheduling all clients on different cpus and let them
> serialize, where we can free those cpus for some other set of clients
> doing something else.

Will this still be true with the DMU?

I don't know which locks are involved at the Lustre level, but the DMU
itself does leaf-level locking of ZAP structures (used for directories).

Cheers,
Ricardo
