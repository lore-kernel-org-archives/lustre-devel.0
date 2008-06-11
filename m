From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Wed, 11 Jun 2008 20:27:07 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <C4754ABB.5AB3%peter.braam@sun.com>
References: <C4754ABB.5AB3%peter.braam@sun.com>
Message-ID: <484FFCDB.4000905@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam wrote:
> This shows a fundamental mistake, and one I was afraid of.  If a second
> client only reads uncommitted data there is already a dependency.

actually we've discussed this many times and this is known property.

thanks, Alex
