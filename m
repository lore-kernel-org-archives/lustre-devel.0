From: Dmitriy Cherkasov <dmitriy@oss-tech.org>
Date: Thu, 6 Jul 2017 12:14:04 -0700
Subject: [lustre-devel] [PATCH v4] staging: lustre: lnet: remove dead
 code and crc32_le() wrapper
In-Reply-To: <1498801841-5799-1-git-send-email-dmitriy@oss-tech.org>
References: <1498794766-12298-1-git-send-email-dmitriy@oss-tech.org>
	<1498801841-5799-1-git-send-email-dmitriy@oss-tech.org>
Message-ID: <71e755f4-eac5-f74f-7add-399355141b16@oss-tech.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On 06/29/2017 10:50 PM, Dmitriy Cherkasov wrote:
> After removing code which was permanently disabled with ifdefs, the
> function ksocknal_csum() becomes just a wrapper for crc32_le(). Remove
> this useless wrapper and instead call crc32_le() directly.
> 

Any feedback on v4 please?
