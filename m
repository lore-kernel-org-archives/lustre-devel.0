From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 4 May 2016 18:10:44 +0000
Subject: [lustre-devel] New wiki documentation
Message-ID: <D34F9639.144AC8%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

James,
would it make sense/is it possible to have a default module parameters for MLX4 and/or MLX5 in ko2iblnd.conf that "do the right thing" to avoid the need for users to deal with this, or is that not possible due to conflicting requirements between these two drivers?

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel High Performance Data Division

On 2016/05/04, 09:06, "lustre-devel on behalf of Simmons, James A." <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> on behalf of simmonsja at ornl.gov<mailto:simmonsja@ornl.gov>> wrote:

Hello folks

    I have added new documentation to the wiki. The first doc is about the upstream
client which can be found at:

http://wiki.lustre.org/Development#Upstream_contributing

People have also been approaching me about how to get mlx4 hardware working with
mlx5 hardware so I wrote a wiki about what I did at:

http://wiki.lustre.org/Infiniband_Configuration_Howto
