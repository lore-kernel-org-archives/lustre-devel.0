From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 28 Oct 2015 19:00:29 +0000
Subject: [lustre-devel] [PATCH 5/5] staging:lustre: Update license and
 copyright for kernel comm
In-Reply-To: <562E051D.6030807@gmail.com>
References: <562E051D.6030807@gmail.com>
Message-ID: <ef7c51eacffd4e9880cd39c0ede13348@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>
>> - * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
>> - *
>> - * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
>> - * CA 95054 USA or visit www.sun.com if you need additional information or
>> - * have any questions.
>
>That text is in every files. You should kill all references.

That would be a mighty big patch.  A patch already exist in our development branch
to update the copyright so that will be eventually backported to the staging tree.
I can look into updating the rest after the copyright patch lands. Then I will port to the
staging tree.
