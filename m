From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 22 Dec 2008 17:45:57 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
 long and dry].
In-Reply-To: <18767.41574.948255.718042@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<200812221648.19278.alexander.zarochentsev@sun.com>
	<18767.41574.948255.718042@gargle.gargle.HOWL>
Message-ID: <494FA825.4080406@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> All in all, I have a feeling that _all_ such algorithms have similar
> communication overhead for the `usual' workload.

not sure what you meant by "such" and "usual", but dependency-based
recovery may have zero overhead for "usual local" workload, in terms
of network and disk traffic.

thanks, Alex
