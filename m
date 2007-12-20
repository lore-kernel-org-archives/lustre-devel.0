From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 20 Dec 2007 13:36:14 -0700
Subject: [Lustre-devel] another use of MD request scheduling
Message-ID: <476AD23E.2080107@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The metadata request scheduler could pre-fetch data from disk that will 
be required for executing the operation.  This has been found to be very 
beneficial in many other applications.

- peter -
