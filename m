Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D7211C48BF8
	for <lustre-devel@archiver.kernel.org>; Thu, 22 Feb 2024 21:13:07 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Tgm3K1txQz22W6;
	Thu, 22 Feb 2024 13:09:01 -0800 (PST)
Received: from mail-pl1-f174.google.com (mail-pl1-f174.google.com
 [209.85.214.174])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Tgm2k20c5z22VH
 for <lustre-devel@lists.lustre.org>; Thu, 22 Feb 2024 13:08:30 -0800 (PST)
Received: by mail-pl1-f174.google.com with SMTP id
 d9443c01a7336-1dc1ff3ba1aso598115ad.3
 for <lustre-devel@lists.lustre.org>; Thu, 22 Feb 2024 13:08:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=dilger-ca.20230601.gappssmtp.com; s=20230601; t=1708636021; x=1709240821;
 darn=lists.lustre.org; 
 h=message-id:to:references:subject:date:mime-version:from:from:to:cc
 :subject:date:message-id:reply-to;
 bh=Hchs7sUXILEGsXc6IyiGD4lcEwu8ot4RAD0tbA5+E9o=;
 b=Pzv+ZQLQKTKkqqWFz+6j2bIXvUtQApK655YETOaiK7mK1/ubGFf26q9p9pu7/k9qYk
 Q4N75sHiXC/Mia96leU0JrQu3wyPKkomFovgxfZKeaxQlkhgoiB+zGTC55O3FVhAgob1
 AWctT5u7HDy8+SicHpO7Ky9/1AKD49a4gzonyGmMuJyBusRY4uGK+5k/Of+Fr/2SWaCj
 Mo7tKgeT3lbQ6OfEs9PvmYFwjZmjTehL4HlTQR7RYPqtFqN7Dt+82V9vLzVBZLC35M9M
 omgCi4ZDtGz7fQVR4K7EfS0XClqRsVVsTJxZN/4QdsvxsyjtN9Zmtbg+zN+KfzR7VQSA
 wuCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1708636021; x=1709240821;
 h=message-id:to:references:subject:date:mime-version:from
 :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=Hchs7sUXILEGsXc6IyiGD4lcEwu8ot4RAD0tbA5+E9o=;
 b=ZA2mFI8Sd2JlzpiRH/hpotopHM2P+uFNRsPlkk/gMZOMEsDZCt2KDOUZ4ITCLZqzMx
 jZJJhXJpdul07xWNbOcXU/uR622MHVFF2OL+AoJAeG2/UWsmJv05+VTJhdvbCQw+1H4H
 FPeRB+yXzDzJY0p/bbu6/J+G8oxcAtcWfiY82GGDL8u5yb9twSQydoiASjfkEHU4UfoP
 PtKkHFj3cEThO0jxQmqaOIRrFkdyPR26u7HnAwiX8C9POzWf8dpjgRVbyj9CwHTtwFEH
 CzD9igkhEyEI9H+QEnkl9yqm7/nhpsgQksy0lkBa/xnALU00NAaqslgCOdZ1/rlmW6Qu
 +6tA==
X-Gm-Message-State: AOJu0YwIHouLk307Xxo5WEStxyYON/JAq5XfD/gosTaGhrrtlyY+5kqy
 NnU5m3Yx7FaPUNY+WFQeI8S1Kwq44czExcGWP1AtWSdlAB+qoaRYwjWmzSGEMYPYLMLg02cci/D
 j
X-Google-Smtp-Source: AGHT+IGzpN0PTwt69IIXAmIZY+4LSE2SHKEgiRGjFtETDINbSzdl6klQVjKCHfKidcCjfYK74bIU5A==
X-Received: by 2002:a17:902:d503:b0:1db:c84c:3549 with SMTP id
 b3-20020a170902d50300b001dbc84c3549mr51349plg.11.1708636021354; 
 Thu, 22 Feb 2024 13:07:01 -0800 (PST)
Received: from cabot.adilger.int (S01068c763f81ca4b.cg.shawcable.net.
 [70.77.200.158]) by smtp.gmail.com with ESMTPSA id
 lk15-20020a17090308cf00b001db40c0ed23sm10343608plb.62.2024.02.22.13.07.00
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Thu, 22 Feb 2024 13:07:00 -0800 (PST)
From: Andreas Dilger <adilger@dilger.ca>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Date: Thu, 22 Feb 2024 14:04:34 -0700
References: <20240222203726.1101861-1-willy@infradead.org>
To: lustre-devel@lists.lustre.org
Message-Id: <A0C6099B-2E8F-49A9-9E6C-6A36DFF7DAC3@dilger.ca>
X-Mailer: Apple Mail (2.3273)
Subject: [lustre-devel] Fwd: [PATCH 0/1] Rosebush, a new hash table
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============6727254634505109017=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============6727254634505109017==
Content-Type: multipart/signed;
 boundary="Apple-Mail=_4B6DE069-3094-4F95-8FAF-62F40BE60737";
 protocol="application/pgp-signature"; micalg=pgp-sha256


--Apple-Mail=_4B6DE069-3094-4F95-8FAF-62F40BE60737
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_68182F8D-B727-4450-A8F2-ECCAAE238BCB"


--Apple-Mail=_68182F8D-B727-4450-A8F2-ECCAAE238BCB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Time to start replacing the use of rhashtable in the code? :-)

> Begin forwarded message:
>=20
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> Subject: [PATCH 0/1] Rosebush, a new hash table
> Date: February 22, 2024 at 1:37:23 PM MST
> To: linux-kernel@vger.kernel.org
> Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>, Thomas Graf =
<tgraf@suug.ch>, Herbert Xu <herbert@gondor.apana.org.au>, =
netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, =
maple-tree@lists.infradead.org, rcu@vger.kernel.org
>=20
> Rosebush is a resizing, scalable, cache-aware, RCU optimised hash =
table.
> I've written a load of documentation about how it works, mostly in
> Documentation/core-api/rosebush.rst but some is dotted through the
> rosebush.c file too.
>=20
> You can see this code as a further exploration of the "Linked lists =
are
> evil" design space.  For the workloads which a hashtable is suited to,
> it has lower overhead than either the maple tree or the rhashtable.
> It cannot support ranges (so is not a replacement for the maple tree),
> but it does have per-bucket locks so is more scalable for write-heavy
> workloads.  I suspect one could reimplement the rhashtable API on top
> of the rosebush, but I am not interested in doing that work myself.
>=20
> The per-object overhead is 12 bytes, as opposed to 16 bytes for the
> rhashtable and 32 bytes for the maple tree.  The constant overhead is =
also
> small, being just 16 bytes for the struct rosebush.  The exact amount
> of memory consumed for a given number of objects is going to depend on
> the distribution of hashes; here are some estimated consumptions for
> power-of-ten entries distributed evenly over a 32-bit hash space in =
the
> various data structures:
>=20
> number	xarray	maple	rhash	rosebush
> 1	3472	272	280	256
> 10	32272	784	424	256
> 100	262kB	3600	1864	2080
> 1000	[1]	34576	17224	16432
> 10k	[1]	343k	168392	131344
> 100k	[1]	3.4M	1731272	2101264
>=20
> As you can see, rosebush and rhashtable are close the whole way.
> Rosebush moves in larger chunks because it doubles each time; there's
> no actual need to double the bucket size, but that works well with
> the slab allocator's existing slabs.  As noted in the documentation,
> we could create our own slabs and get closer to the 12 bytes per =
object
> minimum consumption. [2]
>=20
> Where I expect rosebush to shine is on dependent cache misses.
> I've assumed an average chain length of 10 for rhashtable in the above
> memory calculations.  That means on average a lookup would take five =
cache
> misses that can't be speculated.  Rosebush does a linear walk of =
4-byte
> hashes looking for matches, so the CPU can usefully speculate the =
entire
> array of hash values (indeed, we tell it exactly how many we're going =
to
> look at) and then take a single cache miss fetching the correct =
pointer.
> Add that to the cache miss to fetch the bucket and that's just two =
cache
> misses rather than five.
>=20
> I have not yet converted any code to use the rosebush.  The API is
> designed for use by the dcache, and I expect it will evolve as it =
actually
> gets used.  I think there's probably some more refactoring to be done.
> I am not aware of any bugs, but the test suite is pitifully small.
> The current algorithm grows the buckets more aggressively than the =
table;
> that's probably exactly the wrong thing to do for good performance.
>=20
> This version is full of debugging printks.  You should probably take
> them out if you're going to try to benchmark it.  The regex '^print'
> should find them all.  Contributions welcome; I really want to get =
back
> to working on folios, but this felt like an urgent problem to be =
fixed.
>=20
> [1] I stopped trying to estimate the memory costs for xarray; I =
couldn't
> be bothered to as it's not a serious competitor for this use case.
>=20
> [2] We have ideas for improving the maple tree memory consumption for
> this kind of workload; a new node type for pivots that fit in 4 bytes =
and
> sparse nodes to avoid putting a NULL entry after each occupied entry.
> The maple tree really is optimised for densely packed ranges at the
> moment.
>=20
> Matthew Wilcox (Oracle) (1):
>  rosebush: Add new data structure
>=20
> Documentation/core-api/index.rst    |   1 +
> Documentation/core-api/rosebush.rst | 135 ++++++
> MAINTAINERS                         |   8 +
> include/linux/rosebush.h            |  41 ++
> lib/Kconfig.debug                   |   3 +
> lib/Makefile                        |   3 +-
> lib/rosebush.c                      | 707 ++++++++++++++++++++++++++++
> lib/test_rosebush.c                 | 135 ++++++
> 8 files changed, 1032 insertions(+), 1 deletion(-)
> create mode 100644 Documentation/core-api/rosebush.rst
> create mode 100644 include/linux/rosebush.h
> create mode 100644 lib/rosebush.c
> create mode 100644 lib/test_rosebush.c
>=20
> --
> 2.43.0
>=20
>=20


Cheers, Andreas






--Apple-Mail=_68182F8D-B727-4450-A8F2-ECCAAE238BCB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dus-ascii"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D"">Time to start replacing the use of rhashtable in the code? =
:-)<br class=3D""><div><br class=3D""><blockquote type=3D"cite" =
class=3D""><div class=3D"">Begin forwarded message:</div><br =
class=3D"Apple-interchange-newline"><div style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px;" class=3D""><span=
 style=3D"font-family: -webkit-system-font, Helvetica Neue, Helvetica, =
sans-serif; color:rgba(0, 0, 0, 1.0);" class=3D""><b class=3D"">From: =
</b></span><span style=3D"font-family: -webkit-system-font, Helvetica =
Neue, Helvetica, sans-serif;" class=3D"">"Matthew Wilcox (Oracle)" =
&lt;<a href=3D"mailto:willy@infradead.org" =
class=3D"">willy@infradead.org</a>&gt;<br class=3D""></span></div><div =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px;" class=3D""><span style=3D"font-family: =
-webkit-system-font, Helvetica Neue, Helvetica, sans-serif; =
color:rgba(0, 0, 0, 1.0);" class=3D""><b class=3D"">Subject: =
</b></span><span style=3D"font-family: -webkit-system-font, Helvetica =
Neue, Helvetica, sans-serif;" class=3D""><b class=3D"">[PATCH 0/1] =
Rosebush, a new hash table</b><br class=3D""></span></div><div =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px;" class=3D""><span style=3D"font-family: =
-webkit-system-font, Helvetica Neue, Helvetica, sans-serif; =
color:rgba(0, 0, 0, 1.0);" class=3D""><b class=3D"">Date: =
</b></span><span style=3D"font-family: -webkit-system-font, Helvetica =
Neue, Helvetica, sans-serif;" class=3D"">February 22, 2024 at 1:37:23 PM =
MST<br class=3D""></span></div><div style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px;" class=3D""><span=
 style=3D"font-family: -webkit-system-font, Helvetica Neue, Helvetica, =
sans-serif; color:rgba(0, 0, 0, 1.0);" class=3D""><b class=3D"">To: =
</b></span><span style=3D"font-family: -webkit-system-font, Helvetica =
Neue, Helvetica, sans-serif;" class=3D""><a =
href=3D"mailto:linux-kernel@vger.kernel.org" =
class=3D"">linux-kernel@vger.kernel.org</a><br =
class=3D""></span></div><div style=3D"margin-top: 0px; margin-right: =
0px; margin-bottom: 0px; margin-left: 0px;" class=3D""><span =
style=3D"font-family: -webkit-system-font, Helvetica Neue, Helvetica, =
sans-serif; color:rgba(0, 0, 0, 1.0);" class=3D""><b class=3D"">Cc: =
</b></span><span style=3D"font-family: -webkit-system-font, Helvetica =
Neue, Helvetica, sans-serif;" class=3D"">"Matthew Wilcox (Oracle)" =
&lt;<a href=3D"mailto:willy@infradead.org" =
class=3D"">willy@infradead.org</a>&gt;, Thomas Graf &lt;<a =
href=3D"mailto:tgraf@suug.ch" class=3D"">tgraf@suug.ch</a>&gt;, Herbert =
Xu &lt;<a href=3D"mailto:herbert@gondor.apana.org.au" =
class=3D"">herbert@gondor.apana.org.au</a>&gt;, <a =
href=3D"mailto:netdev@vger.kernel.org" =
class=3D"">netdev@vger.kernel.org</a>, <a =
href=3D"mailto:linux-fsdevel@vger.kernel.org" =
class=3D"">linux-fsdevel@vger.kernel.org</a>, <a =
href=3D"mailto:maple-tree@lists.infradead.org" =
class=3D"">maple-tree@lists.infradead.org</a>, <a =
href=3D"mailto:rcu@vger.kernel.org" class=3D"">rcu@vger.kernel.org</a><br =
class=3D""></span></div><br class=3D""><div class=3D""><div =
class=3D"">Rosebush is a resizing, scalable, cache-aware, RCU optimised =
hash table.<br class=3D"">I've written a load of documentation about how =
it works, mostly in<br class=3D"">Documentation/core-api/rosebush.rst =
but some is dotted through the<br class=3D"">rosebush.c file too.<br =
class=3D""><br class=3D"">You can see this code as a further exploration =
of the "Linked lists are<br class=3D"">evil" design space. &nbsp;For the =
workloads which a hashtable is suited to,<br class=3D"">it has lower =
overhead than either the maple tree or the rhashtable.<br class=3D"">It =
cannot support ranges (so is not a replacement for the maple tree),<br =
class=3D"">but it does have per-bucket locks so is more scalable for =
write-heavy<br class=3D"">workloads. &nbsp;I suspect one could =
reimplement the rhashtable API on top<br class=3D"">of the rosebush, but =
I am not interested in doing that work myself.<br class=3D""><br =
class=3D"">The per-object overhead is 12 bytes, as opposed to 16 bytes =
for the<br class=3D"">rhashtable and 32 bytes for the maple tree. =
&nbsp;The constant overhead is also<br class=3D"">small, being just 16 =
bytes for the struct rosebush. &nbsp;The exact amount<br class=3D"">of =
memory consumed for a given number of objects is going to depend on<br =
class=3D"">the distribution of hashes; here are some estimated =
consumptions for<br class=3D"">power-of-ten entries distributed evenly =
over a 32-bit hash space in the<br class=3D"">various data =
structures:<br class=3D""><br class=3D"">number<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>xarray<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>maple<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>rhash<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>rosebush<br class=3D"">1<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>3472<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>272<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>280<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>256<br class=3D"">10<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>32272<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>784<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>424<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>256<br class=3D"">100<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>262kB<span class=3D"Apple-tab-span"=
 style=3D"white-space:pre">	</span>3600<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>1864<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>2080<br class=3D"">1000<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>[1]<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>34576<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>17224<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>16432<br class=3D"">10k<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>[1]<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>343k<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>168392<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>131344<br =
class=3D"">100k<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>[1]<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>3.4M<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>1731272<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>2101264<br class=3D""><br class=3D"">As you can see, rosebush and =
rhashtable are close the whole way.<br class=3D"">Rosebush moves in =
larger chunks because it doubles each time; there's<br class=3D"">no =
actual need to double the bucket size, but that works well with<br =
class=3D"">the slab allocator's existing slabs. &nbsp;As noted in the =
documentation,<br class=3D"">we could create our own slabs and get =
closer to the 12 bytes per object<br class=3D"">minimum consumption. =
[2]<br class=3D""><br class=3D"">Where I expect rosebush to shine is on =
dependent cache misses.<br class=3D"">I've assumed an average chain =
length of 10 for rhashtable in the above<br class=3D"">memory =
calculations. &nbsp;That means on average a lookup would take five =
cache<br class=3D"">misses that can't be speculated. &nbsp;Rosebush does =
a linear walk of 4-byte<br class=3D"">hashes looking for matches, so the =
CPU can usefully speculate the entire<br class=3D"">array of hash values =
(indeed, we tell it exactly how many we're going to<br class=3D"">look =
at) and then take a single cache miss fetching the correct pointer.<br =
class=3D"">Add that to the cache miss to fetch the bucket and that's =
just two cache<br class=3D"">misses rather than five.<br class=3D""><br =
class=3D"">I have not yet converted any code to use the rosebush. =
&nbsp;The API is<br class=3D"">designed for use by the dcache, and I =
expect it will evolve as it actually<br class=3D"">gets used. &nbsp;I =
think there's probably some more refactoring to be done.<br class=3D"">I =
am not aware of any bugs, but the test suite is pitifully small.<br =
class=3D"">The current algorithm grows the buckets more aggressively =
than the table;<br class=3D"">that's probably exactly the wrong thing to =
do for good performance.<br class=3D""><br class=3D"">This version is =
full of debugging printks. &nbsp;You should probably take<br =
class=3D"">them out if you're going to try to benchmark it. &nbsp;The =
regex '^print'<br class=3D"">should find them all. &nbsp;Contributions =
welcome; I really want to get back<br class=3D"">to working on folios, =
but this felt like an urgent problem to be fixed.<br class=3D""><br =
class=3D"">[1] I stopped trying to estimate the memory costs for xarray; =
I couldn't<br class=3D"">be bothered to as it's not a serious competitor =
for this use case.<br class=3D""><br class=3D"">[2] We have ideas for =
improving the maple tree memory consumption for<br class=3D"">this kind =
of workload; a new node type for pivots that fit in 4 bytes and<br =
class=3D"">sparse nodes to avoid putting a NULL entry after each =
occupied entry.<br class=3D"">The maple tree really is optimised for =
densely packed ranges at the<br class=3D"">moment.<br class=3D""><br =
class=3D"">Matthew Wilcox (Oracle) (1):<br class=3D""> &nbsp;rosebush: =
Add new data structure<br class=3D""><br class=3D""> =
Documentation/core-api/index.rst &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;1 +<br =
class=3D""> Documentation/core-api/rosebush.rst | 135 ++++++<br =
class=3D""> MAINTAINERS =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| =
&nbsp;&nbsp;8 +<br class=3D""> include/linux/rosebush.h =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| =
&nbsp;41 ++<br class=3D""> lib/Kconfig.debug =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;3 +<br class=3D""> =
lib/Makefile =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| =
&nbsp;&nbsp;3 +-<br class=3D""> lib/rosebush.c =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 707 =
++++++++++++++++++++++++++++<br class=3D""> lib/test_rosebush.c =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;| 135 ++++++<br class=3D""> 8 files changed, 1032 =
insertions(+), 1 deletion(-)<br class=3D""> create mode 100644 =
Documentation/core-api/rosebush.rst<br class=3D""> create mode 100644 =
include/linux/rosebush.h<br class=3D""> create mode 100644 =
lib/rosebush.c<br class=3D""> create mode 100644 lib/test_rosebush.c<br =
class=3D""><br class=3D"">-- <br class=3D"">2.43.0<br class=3D""><br =
class=3D""><br class=3D""></div></div></blockquote></div><br =
class=3D""><div class=3D"">
<span class=3D"Apple-style-span" style=3D"border-collapse: separate; =
color: rgb(0, 0, 0); font-family: Helvetica; font-style: normal; =
font-variant: normal; font-weight: normal; letter-spacing: normal; =
line-height: normal; orphans: 2; text-align: -webkit-auto; text-indent: =
0px; text-transform: none; white-space: normal; widows: 2; word-spacing: =
0px; -webkit-border-horizontal-spacing: 0px; =
-webkit-border-vertical-spacing: 0px; =
-webkit-text-decorations-in-effect: none; -webkit-text-size-adjust: =
auto; -webkit-text-stroke-width: 0px;  "><br class=3D"">Cheers, =
Andreas<br class=3D""><br class=3D""><br class=3D""><br class=3D""><br =
class=3D""></span>

</div>
<br class=3D""></body></html>=

--Apple-Mail=_68182F8D-B727-4450-A8F2-ECCAAE238BCB--

--Apple-Mail=_4B6DE069-3094-4F95-8FAF-62F40BE60737
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAmXXtuIACgkQcqXauRfM
H+CbwBAAlTkcRsZZFO6ctZftlnXIL22GxfPi1cS13G7/sAVO83cbddxtpzh5DSWu
l7yw9cM+uUFiu2t64vlgztd5V9XdKbrxst0d3xItLoI/HSECWoKiky94ROIINKCa
7ar6rcamj5/qWrcsxcIdUk/a9q9umxMzmLm1MYeGpHK5RvxjaJQOR627gbZiCtLe
8E7lH11LhfnmkpHT9L7prML9ZRwc/Yc1bGUp0nk8g9il/JN4FE0u1kLf4mzCyRWr
Cl2a2DU2jGXsDYva6xZfIeWAuWCho32bXgGwJbiVI2t2FjGyYau8ZR1DbdRYOkGr
kfUishBPTnm5DFJaR1PoW9bvzoTWq6BCjzaaBkbB3gY69Nlwe6kMH7Tm7H00E6DH
oUDPu1TyykaF8E6691X9mJV4tott2SsJ7jfgRIrNqOC7RODfjgtJe+zlLXzpeg92
k8dsHWlEFN4mRVf1L8Ao+wnOR1ARmQuP821vUVToFY8kxGz6suAsForZ15enLvpo
mcDF7R1rsHDPHGrTGWwptTpJNwSZ+Hztf4TmHuPgga9aZKlwFpqfhMKgq3+egM3w
XMc6/zxqirv2e9NdzpLowtIBafP7x7vQt+NRvBuHFwhb2ujYdpiQfLaqMGu/tdi5
bIc2I/3ip2UVzKuHHR+pxTAI/WxCRDILpNY3NAmYT3lQ8FwLRo4=
=87Yy
-----END PGP SIGNATURE-----

--Apple-Mail=_4B6DE069-3094-4F95-8FAF-62F40BE60737--

--===============6727254634505109017==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6727254634505109017==--
