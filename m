From: Chris Horn <hornc@cray.com>
Date: Tue, 23 Jun 2009 09:59:43 -0500
Subject: [Lustre-devel] Imperative Recovery - forcing failover server
 stop blocking
In-Reply-To: <20090623145316.GC31668@webber.adilger.int>
References: <4A3AC95A.10302@cray.com>
	<447088AD-0C97-4314-A5AA-D7179C9C5C63@sun.com>
	<4A3C0CF2.1080809@cray.com> <06b201c9f362$49015b20$db041160$@com>
	<4A3FCB96.4010201@cray.com> <003301c9f401$1adb8af0$5092a0d0$@com>
	<20090623145316.GC31668@webber.adilger.int>
Message-ID: <4A40EDDF.3060008@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Okay, thanks everyone for your input.  Utilizing an external source of
client health information is not something that we had incorporated into
our initial design, so when I saw the need for this information I wanted
to ensure that it was in fact necessary.

@Brian, thanks for doing the work on tunable recovery and pointing me to
that patch.
