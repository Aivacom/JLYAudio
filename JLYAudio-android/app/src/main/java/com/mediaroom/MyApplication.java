package com.mediaroom;

import android.app.Application;
import android.support.multidex.MultiDex;

import com.mediaroom.utils.Constant;
import com.mediaroom.utils.FileUtil;

import tv.athena.core.axis.Axis;
import tv.athena.crash.api.ICrashService;
import tv.athena.klog.api.ILogService;
import tv.athena.klog.api.LogLevel;
import tv.athena.util.FP;
import tv.athena.util.ProcessorUtils;
import tv.athena.util.RuntimeInfo;

public class MyApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        MultiDex.install(this);

        //----------------------------公司内部代码-----------------------------------
        RuntimeInfo.INSTANCE.appContext(this)
                /*** Set package name* */
                /*** 设置包名* */
                .packageName(this.getPackageName())
                /*** Save process name* */
                /*** 保存进程名* */
                .processName(ProcessorUtils.INSTANCE.getMyProcessName())
                /** Set whether to debug mode* */
                /** 设置是否是debug 模式* */
                .isDebuggable(true)
                /*** Save whether the current process is the main process* */
                /*** 保存当前进程是否是主进程* */
                .isMainProcess(FP.eq(RuntimeInfo.sPackageName, RuntimeInfo.sProcessName));

        /*** Initializing KLog, It's the default configuration now * */
        /*** 初始化 KLog  现在是默认配置* */
        Axis.Companion.getService(ILogService.class).config()
                /*** Set the upper limit of storage log memory */
                /*** 设置存储日志内存上限*/
                .logCacheMaxSiz(100 * 1024 * 1024)
                /*** Maximum single log file*/
                /*** 单个log文件最大值*/
                .singleLogMaxSize(4 * 1024 * 1024)
                /*** Set log write level*/
                /*** 设置日志写入级别*/
                .logLevel(LogLevel.INSTANCE.getLEVEL_VERBOSE())
                /*** Set process ID*/
                /*** 设置进程标识* */
                .processTag(Constant.FEEDBACK_CRASHLOGID)
                .logPath(FileUtil.getLog(this))
                .apply();

        //通过Axis初始化crash服务（Initialize the crash service via Axis）
        Axis.Companion.getService(ICrashService.class).start(Constant.FEEDBACK_CRASHLOGID, "");
        //----------------------------公司内部代码-----------------------------------
    }
}
