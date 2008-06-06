From: Eric Mei <Eric.Mei@Sun.COM>
Date: Fri, 06 Jun 2008 09:16:13 -0600
Subject: [Lustre-devel] security: MGS connection
In-Reply-To: <C46DFA03.5872%peter.braam@sun.com>
References: <C46DFA03.5872%peter.braam@sun.com>
Message-ID: <484954BD.6060508@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam wrote:
> Out of curiosity - do we secure OSC - OST connections with GSS?  We send
> capabilities over them that are encrypted so perhaps it is not necessary.

Yes OSC-OST connection could be configured to use any security flavor.

-- 
Eric
