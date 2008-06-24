From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 24 Jun 2008 12:56:01 -0600
Subject: [Lustre-devel] changelog interface
In-Reply-To: <48601B21.8030209@sun.com>
Message-ID: <C4869F62.5FAB%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Makes sense.

Peter


On 6/23/08 11:52 PM, "Nathaniel Rutman" <Nathan.Rutman@Sun.COM> wrote:

> Peter, early in the changelog arch we had designed the changelog user
> API as a series of files that would show up under a special .lustre
> directory.  After the ZFS changelog investigation, I think it makes more
> sense to try and match the ZFS API so that changes to user tools are
> minimized.
> 
> So, as "zfs diff snap1 snap2" produces a stream to stdout, I think we
> should make "lctl diff startrec [endrec]" produce a similar stream.  We
> would also need a "lctl purge endrec" to clear out old changelog records.
> 
> Any objections?
> 
