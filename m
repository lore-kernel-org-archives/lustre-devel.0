From: Johann Lombardi <johann@sun.com>
Date: Fri, 06 Jun 2008 09:33:13 +0200
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C46D3C11.5835%peter.braam@sun.com>
References: <20080605122708.GR6283@lore> <C46D3C11.5835%peter.braam@sun.com>
Message-ID: <20080606073313.GA21875@lore>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 05, 2008 at 06:45:36AM -0700, Peter Braam wrote:
> Well, this protocol hasn't been published yet; why not include the server
> side uid / gid then?

I understood from Fanyong that according to the remote client design
requirements, we should not allow the remote client to access the server-side
uid/gid mapping.

> But more seriously, how is this encoded in such a way that the OST can trust
> the information - it must be in the capability too?

hmm, I don't see any capability associated with this.

Johann
