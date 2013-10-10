From: Wendy Cheng <s.wendy.cheng@gmail.com>
Date: Thu, 10 Oct 2013 10:05:56 -0700
Subject: [Lustre-devel] Lustre on Intel Xeon Phi
In-Reply-To: <9FC73D3DBECE0941BD2ED069D268634216EBF312@IRSMSX105.ger.corp.intel.com>
References: <CABgxfbFoC1bh4zmJmgZJuufN1zViO1e7AogvVMkeOzVRuPw0hw@mail.gmail.com>
	<9FC73D3DBECE0941BD2ED069D268634216EBEEAB@IRSMSX105.ger.corp.intel.com>
	<CABgxfbGSgeNHx0AT+8WeYigM==TpEL5Ecrn-Qk=YDGFCxwiQyQ@mail.gmail.com>
	<9FC73D3DBECE0941BD2ED069D268634216EBF312@IRSMSX105.ger.corp.intel.com>
Message-ID: <CABgxfbFqiqg-w=kCise+x0468UE9YqUrnek7UVTt74nfsLaCvw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Oct 5, 2013 at 3:01 AM, Eremin, Dmitry <dmitry.eremin@intel.com> wrote:
> Sorry, after recent reorganization it was broken. I will fix this. But now you can just remove "--disable-tests" option from configure. The build will be a bit longer but error should gone. Those binaries produced for testing needs.
>

Thanks for the help ! The Xeon Phi Lustre client is now up and running
on top of Infiniband RDMA using

* Intel Xeon Phi MPSS 2.1 (mpss_gold_update_3-2.1.6720-16)
* Lustre-release from git master branch
* A private version of OFED

There was a kernel panic at lmv_get_info() during mount time but the
problem has been fixed. As the issue seems to be generic (not MPSS
specific), will start another thread to discuss it.

Again, your responses and help are very appreciated.

-- Wendy
