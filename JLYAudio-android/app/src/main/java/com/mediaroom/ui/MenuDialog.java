package com.mediaroom.ui;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.mediaroom.R;
import com.mediaroom.adapter.MenuAdapter;
import com.mediaroom.base.BaseAdapter.OnItemClickListener;

import java.util.List;

/**
 *
 * Menu Dialog
 *
 * ZH：
 * 菜单dailog
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2019/12/31
 */
public class MenuDialog extends BottomSheetDialog {

  private RecyclerView recyclerView;
  private TextView btCancel;
  private List<String> list;
  private OnItemSelectedListener listener;

  public MenuDialog(@NonNull Context context, List<String> list, OnItemSelectedListener listener) {
    super(context);
    this.list = list;
    this.listener = listener;
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.layout_menu);
    getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

    recyclerView = findViewById(R.id.rvList);
    recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
    DividerItemDecoration itemDecoration = new DividerItemDecoration(getContext(),
            DividerItemDecoration.VERTICAL);
    itemDecoration.setDrawable(
            new ColorDrawable(ContextCompat.getColor(getContext(), R.color.bg_grey)));
    recyclerView.addItemDecoration(itemDecoration);
    recyclerView.setItemAnimator(new DefaultItemAnimator());
    MenuAdapter adapter = new MenuAdapter(list, getContext());
    adapter.setOnItemClickListener(new OnItemClickListener() {
      @Override
      public void onItemClick(View view, int position) {
        listener.onItemSelected(position);
        dismiss();
      }
    });
    recyclerView.setAdapter(adapter);

    btCancel = findViewById(R.id.btCancel);
    btCancel.setOnClickListener(v -> {
      dismiss();
    });
  }

  public interface OnItemSelectedListener {

    void onItemSelected(int index);
  }
}
