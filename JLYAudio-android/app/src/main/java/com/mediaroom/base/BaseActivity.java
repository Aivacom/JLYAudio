package com.mediaroom.base;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.v7.app.AppCompatActivity;
import android.widget.Toast;

import com.mediaroom.utils.LoadingDialog;

/**
 * @author zhaochong
 * @desc basic Activity
 * @date on 2019-06-04
 * @email zoro.zhaochong@gmail.com
 */
public abstract class BaseActivity extends AppCompatActivity {

    private LoadingDialog dialog;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setMyContentView();
        initView();
        initData();
    }

    protected void setMyContentView() {
        setContentView(getLayoutResId());
    }

    protected abstract int getLayoutResId();

    protected abstract void initView();

    protected abstract void initData();

    protected void showDialogProgress() {
        if (dialog != null && dialog.isShowing()) {
            return;
        }
        LoadingDialog.Builder builder = new LoadingDialog.Builder(this)
                .setCancelable(false)
                .setCancelOutside(false);
        dialog = builder.create();
        dialog.show();
    }

    protected void dissMissDialogProgress() {
        if (dialog != null) {
            dialog.dismiss();
        }
    }

    protected void showToast(CharSequence text) {
        Toast.makeText(this, text, Toast.LENGTH_SHORT).show();
    }

    protected void showToast(@StringRes int resId) {
        Toast.makeText(this, resId, Toast.LENGTH_SHORT).show();
    }
}

