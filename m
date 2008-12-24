From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Wed, 24 Dec 2008 19:16:23 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <20081223233753.GJ5000@webber.adilger.int>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<494FA7E8.7030200@sun.com>
	<18767.52005.485425.412677@gargle.gargle.HOWL>
	<494FD020.70909@sun.com> <18767.58149.550264.505562@gargle.gargle.HOWL>
	<20081223233753.GJ5000@webber.adilger.int>
Message-ID: <18770.24663.353330.557097@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger writes:
 > Nikita,

Hello,

 > I still need more time to re-read and digest what you have written,
 > but thanks in advance for taking the time to explain it clearly and
 > precisely.  This algorithm does seem to be related to the one originally
 > described in Peter's "Cluster Metadata Recovery" paper where the epoch
 > numbers are pushed and replied by every request, but is much better
 > described.

thanks.

 > I think what would help me understand it a bit easier if it could be more
 > closely mapped onto a potential implementation, and the issues we may see
 > there.  For example, the issue with fsync possibly involving all? nodes
 > (including clients) is not obvious from your description.

I agree with Eric that we can discuss this in more detail in Beijing,
and just want to make one rather obvious remark: your and Alex's
concerns about fsync are indeed justified, because in the global epochs
model fsync is no different from sync, as no per-object dependencies are
tracked. On the other hand, for the target use case of pNFS, where every
operation is synchronous, this is probably less important.

Nikita.
