From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Wed, 08 Jul 2009 21:15:51 +0400
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <20090707161427.GE15302@Sun.COM>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM> <op.uwpaclw3atmt0c@garden>
	<20090707161427.GE15302@Sun.COM>
Message-ID: <4A54D447.5090506@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nicolas Williams wrote:
> Another problem with using locks for open state is that establishing the
> lock atomically with an open w/ create won't be easy.  The MDT would
> have to enqueue a lock for itself atomically with the create, then the
> client would have to enquee its lock, then the MDT would have to drop
> its lock.  Would this not be much more complex that open RPC
> reconstruction?

we already have open locks which are taken in atomical manner with create.

thanks, Alex
