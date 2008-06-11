From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 11 Jun 2008 10:28:23 -0600
Subject: [Lustre-devel] Commit on share
In-Reply-To: <484FFCDB.4000905@sun.com>
Message-ID: <C4755947.5AC7%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I don't know what a known property is but the definition given is not
correct.


On 6/11/08 10:27 AM, "Alex Zhuravlev" <Alex.Zhuravlev@Sun.COM> wrote:

> Peter Braam wrote:
>> This shows a fundamental mistake, and one I was afraid of.  If a second
>> client only reads uncommitted data there is already a dependency.
> 
> actually we've discussed this many times and this is known property.
> 
> thanks, Alex
> 
