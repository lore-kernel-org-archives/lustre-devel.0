From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Tue, 11 Oct 2011 09:34:06 -0400
Subject: [Lustre-devel] IPv6 NIDs
In-Reply-To: <06e901cc8818$95acbc60$c1063520$@com>
References: <06e901cc8818$95acbc60$c1063520$@com>
Message-ID: <20111011093406.3063f001@thirdoffive.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 11 Oct 2011 14:20:44 +0100
"Eric Barton" <eeb@whamcloud.com> wrote:


> 2. Hedge a little by reserving an additional (say) 32 bits for
>    something we've not thought of yet and keeping the total a
>    multiple of 64 bits to simplify alignment.
>    192 bits / 24 bytes total.
>
> 3. Hedge a lot with a nice round number.
>    256 bits / 32 bytes total.

i would pick this.  you never know what address size is coming in the
future for any particular protocol.  the infiniband link layer is
160 bits.  so if someone implemented a 'native' ib solution they
would need 160 + 32 (192).

of course, option 2 would work fine in this case.  however, unless there
is a pressing reason i would just pick 256 because we already have a
case that could use up your 'hedge a little'.
