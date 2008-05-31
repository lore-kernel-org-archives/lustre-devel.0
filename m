From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sat, 31 May 2008 18:25:07 +0800
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18493.30993.371265.613200@gargle.gargle.HOWL>
Message-ID: <C4674883.55E4%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Regardless of how file quota has to be implemented, we do need file quota,
just to be clear.

Peter


On 5/28/08 11:24 PM, "Nikita Danilov" <Nikita.Danilov@Sun.COM> wrote:

> Peter Braam writes:
>> 
>> Why do they not need file quota - what if someone wants to control file
>> count?
> 
> Idea is that support for the inode quota is not necessary is DMU, as
> upper layer can implement it by itself. Compare this with block quotas
> that do require support from DMU, because upper layer cannot generally
> tell overwrite from new-write.
> 
>>> 
> 
> Nikita.
> 
>> 
